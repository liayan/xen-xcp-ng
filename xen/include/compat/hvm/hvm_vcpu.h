#ifndef _COMPAT_HVM_HVM_VCPU_H
#define _COMPAT_HVM_HVM_VCPU_H
#include <xen/compat.h>
#include <public/hvm/hvm_vcpu.h>
#pragma pack(4)
#include "../xen.h"
#pragma pack(4)

struct compat_vcpu_hvm_x86_32 {
    uint32_t eax;
    uint32_t ecx;
    uint32_t edx;
    uint32_t ebx;
    uint32_t esp;
    uint32_t ebp;
    uint32_t esi;
    uint32_t edi;
    uint32_t eip;
    uint32_t eflags;

    uint32_t cr0;
    uint32_t cr3;
    uint32_t cr4;

    uint32_t pad1;

    uint64_t efer;

    uint32_t cs_base;
    uint32_t ds_base;
    uint32_t ss_base;
    uint32_t es_base;
    uint32_t tr_base;
    uint32_t cs_limit;
    uint32_t ds_limit;
    uint32_t ss_limit;
    uint32_t es_limit;
    uint32_t tr_limit;
    uint16_t cs_ar;
    uint16_t ds_ar;
    uint16_t ss_ar;
    uint16_t es_ar;
    uint16_t tr_ar;

    uint16_t pad2[3];
};
struct compat_vcpu_hvm_x86_64 {
    uint64_t rax;
    uint64_t rcx;
    uint64_t rdx;
    uint64_t rbx;
    uint64_t rsp;
    uint64_t rbp;
    uint64_t rsi;
    uint64_t rdi;
    uint64_t rip;
    uint64_t rflags;

    uint64_t cr0;
    uint64_t cr3;
    uint64_t cr4;
    uint64_t efer;
};

struct compat_vcpu_hvm_context {

    uint32_t mode;

    uint32_t pad;

    union {
        struct vcpu_hvm_x86_32 x86_32;
        struct vcpu_hvm_x86_64 x86_64;
    } cpu_regs;
};
typedef struct vcpu_hvm_context vcpu_hvm_context_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_hvm_context_compat_t);
#pragma pack()
#endif /* _COMPAT_HVM_HVM_VCPU_H */
