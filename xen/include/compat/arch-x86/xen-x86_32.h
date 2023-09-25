#ifndef _COMPAT_ARCH_X86_XEN_X86_32_H
#define _COMPAT_ARCH_X86_XEN_X86_32_H
#include <xen/compat.h>
#pragma pack(4)
struct compat_cpu_user_regs {
    __DECL_REG_LO8(b);
    __DECL_REG_LO8(c);
    __DECL_REG_LO8(d);
    __DECL_REG_LO16(si);
    __DECL_REG_LO16(di);
    __DECL_REG_LO16(bp);
    __DECL_REG_LO8(a);
    uint16_t error_code;
    uint16_t entry_vector;
    __DECL_REG_LO16(ip);
    uint16_t cs;
    uint8_t saved_upcall_mask;
    uint8_t _pad0;
    __DECL_REG_LO16(flags);
    __DECL_REG_LO16(sp);
    uint16_t ss, _pad1;
    uint16_t es, _pad2;
    uint16_t ds, _pad3;
    uint16_t fs, _pad4;
    uint16_t gs, _pad5;
};
typedef struct compat_cpu_user_regs cpu_user_regs_compat_t;
DEFINE_COMPAT_HANDLE(cpu_user_regs_compat_t);
struct compat_arch_vcpu_info {
    unsigned int cr2;
    unsigned int pad[5];
};
typedef struct compat_arch_vcpu_info arch_vcpu_info_compat_t;

struct compat_callback {
    unsigned int cs;
    unsigned int eip;
};
typedef struct compat_callback compat_callback_t;
#pragma pack()
#endif /* _COMPAT_ARCH_X86_XEN_X86_32_H */
