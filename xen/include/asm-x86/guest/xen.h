/******************************************************************************
 * asm-x86/guest/xen.h
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms and conditions of the GNU General Public
 * License, version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2017 Citrix Systems Ltd.
 */

#ifndef __X86_GUEST_XEN_H__
#define __X86_GUEST_XEN_H__

#include <xen/types.h>

#include <asm/e820.h>
#include <asm/fixmap.h>

#define XEN_shared_info ((struct shared_info *)fix_to_virt(FIX_XEN_SHARED_INFO))

#ifdef CONFIG_XEN_GUEST

extern bool xen_guest;
extern bool pv_console;

void probe_hypervisor(void);
void hypervisor_setup(void);
void hypervisor_ap_setup(void);
int hypervisor_alloc_unused_page(mfn_t *mfn);
int hypervisor_free_unused_page(mfn_t mfn);
uint32_t hypervisor_cpuid_base(void);
void hypervisor_resume(void);
/*
 * L0 assisted TLB flush.
 * mask: cpumask of the dirty vCPUs that should be flushed.
 * va: linear address to flush, or NULL for global flushes.
 * order: order of the linear address pointed by va.
 */
int hypervisor_flush_tlb(const cpumask_t *mask, const void *va,
                         unsigned int order);

DECLARE_PER_CPU(unsigned int, vcpu_id);
DECLARE_PER_CPU(struct vcpu_info *, vcpu_info);

#else

#define xen_guest 0
#define pv_console 0

static inline void probe_hypervisor(void) {}

static inline void hypervisor_setup(void)
{
    ASSERT_UNREACHABLE();
}
static inline void hypervisor_ap_setup(void)
{
    ASSERT_UNREACHABLE();
}
static inline int hypervisor_flush_tlb(const cpumask_t *mask, const void *va,
                                       unsigned int order)
{
    return -EOPNOTSUPP;
}

#endif /* CONFIG_XEN_GUEST */
#endif /* __X86_GUEST_XEN_H__ */

/*
 * Local variables:
 * mode: C
 * c-file-style: "BSD"
 * c-basic-offset: 4
 * tab-width: 4
 * indent-tabs-mode: nil
 * End:
 */
