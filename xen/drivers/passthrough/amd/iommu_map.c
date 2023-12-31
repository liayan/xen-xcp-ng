/*
 * Copyright (C) 2007 Advanced Micro Devices, Inc.
 * Author: Leo Duran <leo.duran@amd.com>
 * Author: Wei Wang <wei.wang2@amd.com> - adapted to xen
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; If not, see <http://www.gnu.org/licenses/>.
 */

#include <xen/acpi.h>
#include <xen/sched.h>
#include <asm/p2m.h>
#include <asm/amd-iommu.h>
#include <asm/hvm/svm/amd-iommu-proto.h>
#include "../ats.h"
#include <xen/pci.h>

/* Given pfn and page table level, return pde index */
static unsigned int pfn_to_pde_idx(unsigned long pfn, unsigned int level)
{
    unsigned int idx;

    idx = pfn >> (PTE_PER_TABLE_SHIFT * (--level));
    idx &= ~PTE_PER_TABLE_MASK;
    return idx;
}

static unsigned int clear_iommu_pte_present(unsigned long l1_mfn,
                                            unsigned long dfn)
{
    union amd_iommu_pte *table, *pte;
    unsigned int flush_flags;

    table = map_domain_page(_mfn(l1_mfn));
    pte = &table[pfn_to_pde_idx(dfn, 1)];

    flush_flags = pte->pr ? IOMMU_FLUSHF_modified : 0;
    write_atomic(&pte->raw, 0);

    unmap_domain_page(table);

    return flush_flags;
}

static unsigned int set_iommu_pde_present(union amd_iommu_pte *pte,
                                          unsigned long next_mfn,
                                          unsigned int next_level, bool iw,
                                          bool ir)
{
    union amd_iommu_pte new = {}, old;
    unsigned int flush_flags = IOMMU_FLUSHF_added;

    /*
     * FC bit should be enabled in PTE, this helps to solve potential
     * issues with ATS devices
     */
    new.fc = !next_level;

    new.mfn = next_mfn;
    new.iw = iw;
    new.ir = ir;
    new.next_level = next_level;
    new.pr = true;

    old.raw = read_atomic(&pte->raw);
    old.ign0 = 0;
    old.ign1 = 0;
    old.ign2 = 0;

    if ( old.pr && old.raw != new.raw )
        flush_flags |= IOMMU_FLUSHF_modified;

    write_atomic(&pte->raw, new.raw);

    return flush_flags;
}

static unsigned int set_iommu_pte_present(unsigned long pt_mfn,
                                          unsigned long dfn,
                                          unsigned long next_mfn,
                                          int pde_level,
                                          bool iw, bool ir)
{
    union amd_iommu_pte *table, *pde;
    unsigned int flush_flags;

    table = map_domain_page(_mfn(pt_mfn));
    pde = &table[pfn_to_pde_idx(dfn, pde_level)];

    flush_flags = set_iommu_pde_present(pde, next_mfn, 0, iw, ir);
    unmap_domain_page(table);

    return flush_flags;
}

/*
 * This function returns
 * - -errno for errors,
 * - 0 for a successful update, atomic when necessary
 * - 1 for a successful but non-atomic update, which may need to be warned
 *   about by the caller.
 */
int amd_iommu_set_root_page_table(struct amd_iommu_dte *dte,
                                  uint64_t root_ptr, uint16_t domain_id,
                                  uint8_t paging_mode, unsigned int flags)
{
    bool valid = flags & SET_ROOT_VALID;

    if ( dte->v && dte->tv &&
         (cpu_has_cx16 || (flags & SET_ROOT_WITH_UNITY_MAP)) )
    {
        union {
            struct amd_iommu_dte dte;
            uint64_t raw64[4];
            __uint128_t raw128[2];
        } ldte = { .dte = *dte };
        __uint128_t old = ldte.raw128[0];
        int ret = 0;

        ldte.dte.domain_id = domain_id;
        ldte.dte.pt_root = paddr_to_pfn(root_ptr);
        ldte.dte.iw = true;
        ldte.dte.ir = true;
        ldte.dte.paging_mode = paging_mode;
        ldte.dte.v = valid;

        if ( cpu_has_cx16 )
        {
            __uint128_t res = cmpxchg16b(dte, &old, &ldte.raw128[0]);

            /*
             * Hardware does not update the DTE behind our backs, so the
             * return value should match "old".
             */
            if ( res != old )
            {
                printk(XENLOG_ERR
                       "Dom%d: unexpected DTE %016lx_%016lx (expected %016lx_%016lx)\n",
                       domain_id,
                       (uint64_t)(res >> 64), (uint64_t)res,
                       (uint64_t)(old >> 64), (uint64_t)old);
                ret = -EILSEQ;
            }
        }
        else /* Best effort, updating domain_id last. */
        {
            uint64_t *ptr = (void *)dte;

            write_atomic(ptr + 0, ldte.raw64[0]);
            /* No barrier should be needed between these two. */
            write_atomic(ptr + 1, ldte.raw64[1]);

            ret = 1;
        }

        return ret;
    }

    if ( valid || dte->v )
    {
        dte->tv = false;
        dte->v = true;
        smp_wmb();
    }
    dte->domain_id = domain_id;
    dte->pt_root = paddr_to_pfn(root_ptr);
    dte->iw = true;
    dte->ir = true;
    dte->paging_mode = paging_mode;
    smp_wmb();
    dte->tv = true;
    dte->v = valid;

    return 0;
}

void amd_iommu_set_intremap_table(
    struct amd_iommu_dte *dte, const void *ptr,
    const struct amd_iommu *iommu, bool valid)
{
    if ( ptr )
    {
        dte->it_root = virt_to_maddr(ptr) >> 6;
        dte->int_tab_len = amd_iommu_intremap_table_order(ptr, iommu);
        dte->int_ctl = IOMMU_DEV_TABLE_INT_CONTROL_TRANSLATED;
    }
    else
    {
        dte->it_root = 0;
        dte->int_tab_len = 0;
        dte->int_ctl = IOMMU_DEV_TABLE_INT_CONTROL_ABORTED;
    }

    dte->ig = false; /* unmapped interrupts result in i/o page faults */
    smp_wmb();
    dte->iv = valid;
}

void __init iommu_dte_add_device_entry(struct amd_iommu_dte *dte,
                                       const struct ivrs_mappings *ivrs_dev)
{
    uint8_t flags = ivrs_dev->device_flags;

    *dte = (struct amd_iommu_dte){
        .init_pass = flags & ACPI_IVHD_INIT_PASS,
        .ext_int_pass = flags & ACPI_IVHD_EINT_PASS,
        .nmi_pass = flags & ACPI_IVHD_NMI_PASS,
        .lint0_pass = flags & ACPI_IVHD_LINT0_PASS,
        .lint1_pass = flags & ACPI_IVHD_LINT1_PASS,
        .ioctl = IOMMU_DEV_TABLE_IO_CONTROL_ABORTED,
        .sys_mgt = MASK_EXTR(flags, ACPI_IVHD_SYSTEM_MGMT),
        .ex = ivrs_dev->dte_allow_exclusion,
    };
}

void iommu_dte_set_guest_cr3(struct amd_iommu_dte *dte, uint16_t dom_id,
                             uint64_t gcr3_mfn, bool gv, uint8_t glx)
{
#define GCR3_MASK(hi, lo) (((1ul << ((hi) + 1)) - 1) & ~((1ul << (lo)) - 1))
#define GCR3_SHIFT(lo) ((lo) - PAGE_SHIFT)

    /* I bit must be set when gcr3 is enabled */
    dte->i = true;

    dte->gcr3_trp_14_12 = (gcr3_mfn & GCR3_MASK(14, 12)) >> GCR3_SHIFT(12);
    dte->gcr3_trp_30_15 = (gcr3_mfn & GCR3_MASK(30, 15)) >> GCR3_SHIFT(15);
    dte->gcr3_trp_51_31 = (gcr3_mfn & GCR3_MASK(51, 31)) >> GCR3_SHIFT(31);

    dte->domain_id = dom_id;
    dte->glx = glx;
    dte->gv = gv;

#undef GCR3_SHIFT
#undef GCR3_MASK
}

/* Walk io page tables and build level page tables if necessary
 * {Re, un}mapping super page frames causes re-allocation of io
 * page tables.
 */
static int iommu_pde_from_dfn(struct domain *d, unsigned long dfn,
                              unsigned long pt_mfn[], bool map)
{
    union amd_iommu_pte *pde, *next_table_vaddr;
    unsigned long  next_table_mfn;
    unsigned int level;
    struct page_info *table;
    const struct domain_iommu *hd = dom_iommu(d);

    table = hd->arch.root_table;
    level = hd->arch.paging_mode;

    BUG_ON( table == NULL || level < 1 || level > IOMMU_MAX_PT_LEVELS );

    /*
     * A frame number past what the current page tables can represent can't
     * possibly have a mapping.
     */
    if ( dfn >> (PTE_PER_TABLE_SHIFT * level) )
        return 0;

    next_table_mfn = mfn_x(page_to_mfn(table));

    if ( level == 1 )
    {
        pt_mfn[level] = next_table_mfn;
        return 0;
    }

    while ( level > 1 )
    {
        unsigned int next_level = level - 1;
        pt_mfn[level] = next_table_mfn;

        next_table_vaddr = map_domain_page(_mfn(next_table_mfn));
        pde = &next_table_vaddr[pfn_to_pde_idx(dfn, level)];

        /* Here might be a super page frame */
        next_table_mfn = pde->mfn;

        /* Split super page frame into smaller pieces.*/
        if ( pde->pr && !pde->next_level && next_table_mfn )
        {
            int i;
            unsigned long mfn, pfn;
            unsigned int page_sz;

            page_sz = 1 << (PTE_PER_TABLE_SHIFT * (next_level - 1));
            pfn =  dfn & ~((1 << (PTE_PER_TABLE_SHIFT * next_level)) - 1);
            mfn = next_table_mfn;

            /* allocate lower level page table */
            table = alloc_amd_iommu_pgtable();
            if ( table == NULL )
            {
                AMD_IOMMU_DEBUG("Cannot allocate I/O page table\n");
                unmap_domain_page(next_table_vaddr);
                return 1;
            }

            next_table_mfn = mfn_x(page_to_mfn(table));
            set_iommu_pde_present(pde, next_table_mfn, next_level, true,
                                  true);

            for ( i = 0; i < PTE_PER_TABLE_SIZE; i++ )
            {
                set_iommu_pte_present(next_table_mfn, pfn, mfn, next_level,
                                      true, true);
                mfn += page_sz;
                pfn += page_sz;
             }

            amd_iommu_flush_all_pages(d);
        }

        /* Install lower level page table for non-present entries */
        else if ( !pde->pr )
        {
            if ( !map )
            {
                unmap_domain_page(next_table_vaddr);
                return 0;
            }

            if ( next_table_mfn == 0 )
            {
                table = alloc_amd_iommu_pgtable();
                if ( table == NULL )
                {
                    AMD_IOMMU_DEBUG("Cannot allocate I/O page table\n");
                    unmap_domain_page(next_table_vaddr);
                    return 1;
                }
                next_table_mfn = mfn_x(page_to_mfn(table));
                set_iommu_pde_present(pde, next_table_mfn, next_level, true,
                                      true);
            }
            else /* should never reach here */
            {
                unmap_domain_page(next_table_vaddr);
                return 1;
            }
        }

        unmap_domain_page(next_table_vaddr);
        level--;
    }

    /* mfn of level 1 page table */
    pt_mfn[level] = next_table_mfn;
    return 0;
}

int amd_iommu_map_page(struct domain *d, dfn_t dfn, mfn_t mfn,
                       unsigned int flags, unsigned int *flush_flags)
{
    struct domain_iommu *hd = dom_iommu(d);
    int rc;
    unsigned long pt_mfn[7];

    memset(pt_mfn, 0, sizeof(pt_mfn));

    spin_lock(&hd->arch.mapping_lock);

    rc = amd_iommu_alloc_root(hd);
    if ( rc )
    {
        spin_unlock(&hd->arch.mapping_lock);
        AMD_IOMMU_DEBUG("Root table alloc failed, dfn = %"PRI_dfn"\n",
                        dfn_x(dfn));
        domain_crash(d);
        return rc;
    }

    if ( iommu_pde_from_dfn(d, dfn_x(dfn), pt_mfn, true) || (pt_mfn[1] == 0) )
    {
        spin_unlock(&hd->arch.mapping_lock);
        AMD_IOMMU_DEBUG("Invalid IO pagetable entry dfn = %"PRI_dfn"\n",
                        dfn_x(dfn));
        domain_crash(d);
        return -EFAULT;
    }

    /* Install 4k mapping */
    *flush_flags |= set_iommu_pte_present(pt_mfn[1], dfn_x(dfn), mfn_x(mfn),
                                          1, (flags & IOMMUF_writable),
                                          (flags & IOMMUF_readable));

    spin_unlock(&hd->arch.mapping_lock);

    return 0;
}

int amd_iommu_unmap_page(struct domain *d, dfn_t dfn,
                         unsigned int *flush_flags)
{
    unsigned long pt_mfn[7];
    struct domain_iommu *hd = dom_iommu(d);

    memset(pt_mfn, 0, sizeof(pt_mfn));

    spin_lock(&hd->arch.mapping_lock);

    if ( !hd->arch.root_table )
    {
        spin_unlock(&hd->arch.mapping_lock);
        return 0;
    }

    if ( iommu_pde_from_dfn(d, dfn_x(dfn), pt_mfn, false) )
    {
        spin_unlock(&hd->arch.mapping_lock);
        AMD_IOMMU_DEBUG("Invalid IO pagetable entry dfn = %"PRI_dfn"\n",
                        dfn_x(dfn));
        domain_crash(d);
        return -EFAULT;
    }

    if ( pt_mfn[1] )
    {
        /* Mark PTE as 'page not present'. */
        *flush_flags |= clear_iommu_pte_present(pt_mfn[1], dfn_x(dfn));
    }

    spin_unlock(&hd->arch.mapping_lock);

    return 0;
}

static unsigned long flush_count(unsigned long dfn, unsigned int page_count,
                                 unsigned int order)
{
    unsigned long start = dfn >> order;
    unsigned long end = ((dfn + page_count - 1) >> order) + 1;

    ASSERT(end > start);
    return end - start;
}

int amd_iommu_flush_iotlb_pages(struct domain *d, dfn_t dfn,
                                unsigned int page_count,
                                unsigned int flush_flags)
{
    unsigned long dfn_l = dfn_x(dfn);

    ASSERT(page_count && !dfn_eq(dfn, INVALID_DFN));
    ASSERT(flush_flags);

    /* Unless a PTE was modified, no flush is required */
    if ( !(flush_flags & IOMMU_FLUSHF_modified) )
        return 0;

    /* If the range wraps then just flush everything */
    if ( dfn_l + page_count < dfn_l )
    {
        amd_iommu_flush_all_pages(d);
        return 0;
    }

    /*
     * Flushes are expensive so find the minimal single flush that will
     * cover the page range.
     *
     * NOTE: It is unnecessary to round down the DFN value to align with
     *       the flush order here. This is done by the internals of the
     *       flush code.
     */
    if ( page_count == 1 ) /* order 0 flush count */
        amd_iommu_flush_pages(d, dfn_l, 0);
    else if ( flush_count(dfn_l, page_count, 9) == 1 )
        amd_iommu_flush_pages(d, dfn_l, 9);
    else if ( flush_count(dfn_l, page_count, 18) == 1 )
        amd_iommu_flush_pages(d, dfn_l, 18);
    else
        amd_iommu_flush_all_pages(d);

    return 0;
}

int amd_iommu_flush_iotlb_all(struct domain *d)
{
    amd_iommu_flush_all_pages(d);

    return 0;
}

int amd_iommu_reserve_domain_unity_map(struct domain *d,
                                       const struct ivrs_unity_map *map,
                                       unsigned int flag)
{
    int rc;

    if ( d == dom_io )
        return 0;

    for ( rc = 0; !rc && map; map = map->next )
    {
        p2m_access_t p2ma = p2m_access_n;

        if ( map->read )
            p2ma |= p2m_access_r;
        if ( map->write )
            p2ma |= p2m_access_w;

        rc = iommu_identity_mapping(d, p2ma, map->addr,
                                    map->addr + map->length - 1, flag);
    }

    return rc;
}

int amd_iommu_reserve_domain_unity_unmap(struct domain *d,
                                         const struct ivrs_unity_map *map)
{
    int rc;

    if ( d == dom_io )
        return 0;

    for ( rc = 0; map; map = map->next )
    {
        int ret = iommu_identity_mapping(d, p2m_access_x, map->addr,
                                         map->addr + map->length - 1, 0);

        if ( ret && ret != -ENOENT && !rc )
            rc = ret;
    }

    return rc;
}

static int fill_qpt(union amd_iommu_pte *this, unsigned int level,
                    struct page_info *pgs[IOMMU_MAX_PT_LEVELS],
                    struct pci_dev *pdev)
{
    unsigned int i;
    int rc = 0;

    for ( i = 0; !rc && i < PTE_PER_TABLE_SIZE; ++i )
    {
        union amd_iommu_pte *pte = &this[i], *next;

        if ( !pte->pr )
        {
            if ( !pgs[level] )
            {
                /*
                 * The pgtable allocator is fine for the leaf page, as well as
                 * page table pages, and the resulting allocations are always
                 * zeroed.
                 */
                pgs[level] = alloc_amd_iommu_pgtable();
                if ( !pgs[level] )
                {
                    rc = -ENOMEM;
                    break;
                }

                page_list_add(pgs[level], &pdev->arch.pgtables_list);

                if ( level )
                {
                    next = __map_domain_page(pgs[level]);
                    rc = fill_qpt(next, level - 1, pgs, pdev);
                    unmap_domain_page(next);
                }
            }

            /*
             * PDEs are essentially a subset of PTEs, so this function
             * is fine to use even at the leaf.
             */
            set_iommu_pde_present(pte, mfn_x(page_to_mfn(pgs[level])), level,
                                  true, true);
        }
        else if ( level && pte->next_level )
        {
            page_list_add(mfn_to_page(_mfn(pte->mfn)),
                          &pdev->arch.pgtables_list);
            next = map_domain_page(_mfn(pte->mfn));
            rc = fill_qpt(next, level - 1, pgs, pdev);
            unmap_domain_page(next);
        }
    }

    return rc;
}

int amd_iommu_quarantine_init(struct pci_dev *pdev)
{
    struct domain_iommu *hd = dom_iommu(dom_io);
    unsigned long end_gfn =
        1ul << (DEFAULT_DOMAIN_ADDRESS_WIDTH - PAGE_SHIFT);
    unsigned int level = amd_iommu_get_paging_mode(end_gfn);
    unsigned int req_id = get_dma_requestor_id(pdev->seg, pdev->sbdf.bdf);
    const struct ivrs_mappings *ivrs_mappings = get_ivrs_mappings(pdev->seg);
    int rc;

    ASSERT(pcidevs_locked());
    ASSERT(!hd->arch.root_table);

    ASSERT(pdev->arch.pseudo_domid != DOMID_INVALID);

    if ( pdev->arch.amd.root_table )
    {
        clear_domain_page(pdev->arch.leaf_mfn);
        return 0;
    }

    pdev->arch.amd.root_table = alloc_amd_iommu_pgtable();
    if ( !pdev->arch.amd.root_table )
        return -ENOMEM;

    /* Transiently install the root into DomIO, for iommu_identity_mapping(). */
    hd->arch.root_table = pdev->arch.amd.root_table;

    rc = amd_iommu_reserve_domain_unity_map(dom_io,
                                            ivrs_mappings[req_id].unity_map,
                                            0);

    iommu_identity_map_teardown(dom_io);
    hd->arch.root_table = NULL;

    if ( rc )
        printk("%04x:%02x:%02x.%u: quarantine unity mapping failed\n",
               pdev->seg, pdev->bus,
               PCI_SLOT(pdev->devfn), PCI_FUNC(pdev->devfn));
    else
    {
        union amd_iommu_pte *root;
        struct page_info *pgs[IOMMU_MAX_PT_LEVELS] = {};

        spin_lock(&hd->arch.mapping_lock);

        root = __map_domain_page(pdev->arch.amd.root_table);
        rc = fill_qpt(root, level - 1, pgs, pdev);
        unmap_domain_page(root);

        pdev->arch.leaf_mfn = page_to_mfn(pgs[0]);

        spin_unlock(&hd->arch.mapping_lock);
    }

    if ( rc )
        amd_iommu_quarantine_teardown(pdev);

    return rc;
}

void amd_iommu_quarantine_teardown(struct pci_dev *pdev)
{
    struct page_info *pg;

    ASSERT(pcidevs_locked());

    if ( !pdev->arch.amd.root_table )
        return;

    while ( (pg = page_list_remove_head(&pdev->arch.pgtables_list)) )
        free_amd_iommu_pgtable(pg);

    pdev->arch.amd.root_table = NULL;
}

/*
 * Local variables:
 * mode: C
 * c-file-style: "BSD"
 * c-basic-offset: 4
 * tab-width: 4
 * indent-tabs-mode: nil
 * End:
 */
