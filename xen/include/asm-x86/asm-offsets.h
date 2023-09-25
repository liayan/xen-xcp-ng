/*
 * DO NOT MODIFY.
 *
 * This file was auto-generated from arch/x86/asm-offsets.s
 *
 */

#ifndef __ASM_OFFSETS_H__
#define __ASM_OFFSETS_H__

#define UREGS_r15 0 /* offsetof(struct cpu_user_regs, r15) */
#define UREGS_r14 8 /* offsetof(struct cpu_user_regs, r14) */
#define UREGS_r13 16 /* offsetof(struct cpu_user_regs, r13) */
#define UREGS_r12 24 /* offsetof(struct cpu_user_regs, r12) */
#define UREGS_rbp 32 /* offsetof(struct cpu_user_regs, rbp) */
#define UREGS_rbx 40 /* offsetof(struct cpu_user_regs, rbx) */
#define UREGS_r11 48 /* offsetof(struct cpu_user_regs, r11) */
#define UREGS_r10 56 /* offsetof(struct cpu_user_regs, r10) */
#define UREGS_r9 64 /* offsetof(struct cpu_user_regs, r9) */
#define UREGS_r8 72 /* offsetof(struct cpu_user_regs, r8) */
#define UREGS_rax 80 /* offsetof(struct cpu_user_regs, rax) */
#define UREGS_rcx 88 /* offsetof(struct cpu_user_regs, rcx) */
#define UREGS_rdx 96 /* offsetof(struct cpu_user_regs, rdx) */
#define UREGS_rsi 104 /* offsetof(struct cpu_user_regs, rsi) */
#define UREGS_rdi 112 /* offsetof(struct cpu_user_regs, rdi) */
#define UREGS_error_code 120 /* offsetof(struct cpu_user_regs, error_code) */
#define UREGS_entry_vector 124 /* offsetof(struct cpu_user_regs, entry_vector) */
#define UREGS_rip 128 /* offsetof(struct cpu_user_regs, rip) */
#define UREGS_cs 136 /* offsetof(struct cpu_user_regs, cs) */
#define UREGS_eflags 144 /* offsetof(struct cpu_user_regs, rflags) */
#define UREGS_rsp 152 /* offsetof(struct cpu_user_regs, rsp) */
#define UREGS_ss 160 /* offsetof(struct cpu_user_regs, ss) */
#define UREGS_kernel_sizeof 168 /* offsetof(struct cpu_user_regs, es) */

#define DOMAIN_id 0 /* offsetof(struct domain, domain_id) */
#define DOMAIN_shared_info 16 /* offsetof(struct domain, shared_info) */
#define DOMAIN_next 120 /* offsetof(struct domain, next_in_list) */
#define DOMAIN_max_vcpus 4 /* offsetof(struct domain, max_vcpus) */
#define DOMAIN_vcpus 8 /* offsetof(struct domain, vcpu) */
#define DOMAIN_options 300 /* offsetof(struct domain, options) */
#define DOMAIN_is_privileged 449 /* offsetof(struct domain, is_privileged) */
#define DOMAIN_tot_pages 72 /* offsetof(struct domain, tot_pages) */
#define DOMAIN_max_pages 84 /* offsetof(struct domain, max_pages) */
#define DOMAIN_shr_pages 88 /* offsetof(struct domain, shr_pages) */
#define DOMAIN_has_32bit_shinfo 1897 /* offsetof(struct domain, arch.has_32bit_shinfo) */
#define DOMAIN_pause_count 508 /* offsetof(struct domain, pause_count) */
#define DOMAIN_handle 2312 /* offsetof(struct domain, handle) */
#define DOMAIN_paging_mode 1704 /* offsetof(struct domain, arch.paging.mode) */
#define DOMAIN_sizeof 2688 /* sizeof(struct domain) */

#define SHARED_max_pfn 3088 /* offsetof(struct shared_info, arch.max_pfn) */
#define SHARED_pfn_to_mfn_list_list 3096 /* offsetof(struct shared_info, arch.pfn_to_mfn_frame_list_list) */

#define VIRT_XEN_START -137642964418560 /* XEN_VIRT_START */
#define VIRT_XEN_END -137641890676736 /* XEN_VIRT_END */
#define VIRT_DIRECTMAP_START -137438953472000 /* DIRECTMAP_VIRT_START */
#define VIRT_DIRECTMAP_END -549755813888 /* DIRECTMAP_VIRT_END */
#define XEN_DEBUG 1 /* debug_build() */
#define XEN_STACK_SIZE 32768 /* STACK_SIZE */
#define XEN_PRIMARY_STACK_SIZE 8192 /* PRIMARY_STACK_SIZE */
#define XEN_MEMORY_GUARD 1 /* 1 */
#define XEN_FRAME_POINTER 1 /* 1 */

#define VCPU_vcpu_id 0 /* offsetof(struct vcpu, vcpu_id) */
#define VCPU_processor 4 /* offsetof(struct vcpu, processor) */
#define VCPU_domain 16 /* offsetof(struct vcpu, domain) */
#define VCPU_vcpu_info 8 /* offsetof(struct vcpu, vcpu_info) */
#define VCPU_trap_bounce 1384 /* offsetof(struct vcpu, arch.pv.trap_bounce) */
#define VCPU_thread_flags 840 /* offsetof(struct vcpu, arch.flags) */
#define VCPU_event_addr 1312 /* offsetof(struct vcpu, arch.pv.event_callback_eip) */
#define VCPU_event_sel 1328 /* offsetof(struct vcpu, arch.pv.event_callback_cs) */
#define VCPU_syscall_addr 1328 /* offsetof(struct vcpu, arch.pv.syscall_callback_eip) */
#define VCPU_syscall32_addr 1336 /* offsetof(struct vcpu, arch.pv.syscall32_callback_eip) */
#define VCPU_syscall32_sel 1352 /* offsetof(struct vcpu, arch.pv.syscall32_callback_cs) */
#define VCPU_syscall32_disables_events 1356 /* offsetof(struct vcpu, arch.pv.syscall32_disables_events) */
#define VCPU_sysenter_addr 1344 /* offsetof(struct vcpu, arch.pv.sysenter_callback_eip) */
#define VCPU_sysenter_sel 1354 /* offsetof(struct vcpu, arch.pv.sysenter_callback_cs) */
#define VCPU_sysenter_disables_events 1357 /* offsetof(struct vcpu, arch.pv.sysenter_disables_events) */
#define VCPU_trap_ctxt 1096 /* offsetof(struct vcpu, arch.pv.trap_ctxt) */
#define VCPU_kernel_sp 1240 /* offsetof(struct vcpu, arch.pv.kernel_sp) */
#define VCPU_kernel_ss 1232 /* offsetof(struct vcpu, arch.pv.kernel_ss) */
#define VCPU_iopl 1412 /* offsetof(struct vcpu, arch.pv.iopl) */
#define VCPU_guest_context_flags 584 /* offsetof(struct vcpu, arch.vgc_flags) */
#define VCPU_user_regs 592 /* offsetof(struct vcpu, arch.user_regs) */
#define VCPU_flags 840 /* offsetof(struct vcpu, arch.flags) */
#define VCPU_guest_table_user 2816 /* offsetof(struct vcpu, arch.guest_table_user) */
#define VCPU_guest_table 2824 /* offsetof(struct vcpu, arch.guest_table) */
#define VCPU_cr3 2896 /* offsetof(struct vcpu, arch.cr3) */
#define VCPU_arch_msrs 3312 /* offsetof(struct vcpu, arch.msrs) */
#define VCPU_nmi_pending 274 /* offsetof(struct vcpu, async_exception_state[(1)-1].pending) */
#define VCPU_pause_flags 296 /* offsetof(struct vcpu, pause_flags) */
#define VCPU_pause_count 304 /* offsetof(struct vcpu, pause_count) */
#define VCPU_mce_pending 276 /* offsetof(struct vcpu, async_exception_state[(2)-1].pending) */
#define VCPU_nmi_old_mask 275 /* offsetof(struct vcpu, async_exception_state[(1)-1].old_mask) */
#define VCPU_mce_old_mask 277 /* offsetof(struct vcpu, async_exception_state[(2)-1].old_mask) */
#define VCPU_async_exception_mask 278 /* offsetof(struct vcpu, async_exception_mask) */
#define VCPU_TRAP_NMI 1 /* VCPU_TRAP_NMI */
#define VCPU_TRAP_MCE 2 /* VCPU_TRAP_MCE */
#define _VGCF_syscall_disables_events 4 /* _VGCF_syscall_disables_events */
#define VCPU_sizeof 3328 /* sizeof(struct vcpu) */

#define VCPU_svm_vmcb_pa 1416 /* offsetof(struct vcpu, arch.hvm.svm.vmcb_pa) */
#define VCPU_svm_vmcb 1408 /* offsetof(struct vcpu, arch.hvm.svm.vmcb) */

#define VCPU_vmx_launched 1452 /* offsetof(struct vcpu, arch.hvm.vmx.launched) */
#define VCPU_vmx_realmode 1673 /* offsetof(struct vcpu, arch.hvm.vmx.vmx_realmode) */
#define VCPU_vmx_emulate 1674 /* offsetof(struct vcpu, arch.hvm.vmx.vmx_emulate) */
#define VCPU_vm86_seg_mask 1676 /* offsetof(struct vcpu, arch.hvm.vmx.vm86_segment_mask) */
#define VCPU_hvm_guest_cr2 976 /* offsetof(struct vcpu, arch.hvm.guest_cr[2]) */

#define VCPU_nhvm_guestmode 1896 /* offsetof(struct vcpu, arch.hvm.nvcpu.nv_guestmode) */
#define VCPU_nhvm_p2m 2128 /* offsetof(struct vcpu, arch.hvm.nvcpu.nv_p2m) */
#define VCPU_nsvm_hap_enabled 2084 /* offsetof(struct vcpu, arch.hvm.nvcpu.u.nsvm.ns_hap_enabled) */

#define DOMAIN_is_32bit_pv 1896 /* offsetof(struct domain, arch.is_32bit_pv) */

#define VCPUINFO_upcall_pending 0 /* offsetof(struct vcpu_info, evtchn_upcall_pending) */
#define VCPUINFO_upcall_mask 1 /* offsetof(struct vcpu_info, evtchn_upcall_mask) */

#define COMPAT_VCPUINFO_upcall_pending 0 /* offsetof(struct compat_vcpu_info, evtchn_upcall_pending) */
#define COMPAT_VCPUINFO_upcall_mask 1 /* offsetof(struct compat_vcpu_info, evtchn_upcall_mask) */

#define CPUINFO_guest_cpu_user_regs 0 /* offsetof(struct cpu_info, guest_cpu_user_regs) */
#define CPUINFO_processor_id 200 /* offsetof(struct cpu_info, processor_id) */
#define CPUINFO_verw_sel 204 /* offsetof(struct cpu_info, verw_sel) */
#define CPUINFO_current_vcpu 208 /* offsetof(struct cpu_info, current_vcpu) */
#define CPUINFO_per_cpu_offset 216 /* offsetof(struct cpu_info, per_cpu_offset) */
#define CPUINFO_cr4 224 /* offsetof(struct cpu_info, cr4) */
#define CPUINFO_xen_cr3 232 /* offsetof(struct cpu_info, xen_cr3) */
#define CPUINFO_pv_cr3 240 /* offsetof(struct cpu_info, pv_cr3) */
#define CPUINFO_shadow_spec_ctrl 248 /* offsetof(struct cpu_info, shadow_spec_ctrl) */
#define CPUINFO_xen_spec_ctrl 252 /* offsetof(struct cpu_info, xen_spec_ctrl) */
#define CPUINFO_last_spec_ctrl 253 /* offsetof(struct cpu_info, last_spec_ctrl) */
#define CPUINFO_spec_ctrl_flags 254 /* offsetof(struct cpu_info, spec_ctrl_flags) */
#define CPUINFO_root_pgt_changed 255 /* offsetof(struct cpu_info, root_pgt_changed) */
#define CPUINFO_use_pv_cr3 256 /* offsetof(struct cpu_info, use_pv_cr3) */
#define CPUINFO_sizeof 264 /* sizeof(struct cpu_info) */

#define TRAPINFO_eip 8 /* offsetof(struct trap_info, address) */
#define TRAPINFO_cs 2 /* offsetof(struct trap_info, cs) */
#define TRAPINFO_flags 1 /* offsetof(struct trap_info, flags) */
#define TRAPINFO_sizeof 16 /* sizeof(struct trap_info) */

#define TRAPBOUNCE_error_code 0 /* offsetof(struct trap_bounce, error_code) */
#define TRAPBOUNCE_flags 4 /* offsetof(struct trap_bounce, flags) */
#define TRAPBOUNCE_cs 6 /* offsetof(struct trap_bounce, cs) */
#define TRAPBOUNCE_eip 8 /* offsetof(struct trap_bounce, eip) */

#define VCPUMSR_spec_ctrl_raw 0 /* offsetof(struct vcpu_msrs, spec_ctrl.raw) */

#define IRQSTAT_shift 7 /* ilog2(sizeof(irq_cpustat_t)) */
#define IRQSTAT_softirq_pending 0 /* offsetof(irq_cpustat_t, __softirq_pending) */

#define CPUINFO_features 12 /* offsetof(struct cpuinfo_x86, x86_capability) */

#define MB_flags 0 /* offsetof(multiboot_info_t, flags) */
#define MB_cmdline 16 /* offsetof(multiboot_info_t, cmdline) */
#define MB_mem_lower 4 /* offsetof(multiboot_info_t, mem_lower) */

#define MB2_fixed_sizeof 8 /* sizeof(multiboot2_fixed_t) */
#define MB2_fixed_total_size 0 /* offsetof(multiboot2_fixed_t, total_size) */
#define MB2_tag_type 0 /* offsetof(multiboot2_tag_t, type) */
#define MB2_tag_size 4 /* offsetof(multiboot2_tag_t, size) */
#define MB2_load_base_addr 8 /* offsetof(multiboot2_tag_load_base_addr_t, load_base_addr) */
#define MB2_mem_lower 8 /* offsetof(multiboot2_tag_basic_meminfo_t, mem_lower) */
#define MB2_efi64_st 8 /* offsetof(multiboot2_tag_efi64_t, pointer) */
#define MB2_efi64_ih 8 /* offsetof(multiboot2_tag_efi64_ih_t, pointer) */

#define l2_identmap_sizeof 16384 /* sizeof(l2_identmap) */

#define DOMAIN_vm_assist 520 /* offsetof(struct domain, vm_assist) */
#define LIST_HEAD_next 0 /* offsetof(struct list_head, next) */

#endif
