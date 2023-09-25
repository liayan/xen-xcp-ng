
#define XLAT_cpu_user_regs(_d_, _s_) do { \
    (_d_)->__DECL_REG_LO8(b) = (_s_)->__DECL_REG_LO8(b); \
    (_d_)->__DECL_REG_LO8(c) = (_s_)->__DECL_REG_LO8(c); \
    (_d_)->__DECL_REG_LO8(d) = (_s_)->__DECL_REG_LO8(d); \
    (_d_)->__DECL_REG_LO16(si) = (_s_)->__DECL_REG_LO16(si); \
    (_d_)->__DECL_REG_LO16(di) = (_s_)->__DECL_REG_LO16(di); \
    (_d_)->__DECL_REG_LO16(bp) = (_s_)->__DECL_REG_LO16(bp); \
    (_d_)->__DECL_REG_LO8(a) = (_s_)->__DECL_REG_LO8(a); \
    (_d_)->error_code = (_s_)->error_code; \
    (_d_)->entry_vector = (_s_)->entry_vector; \
    (_d_)->__DECL_REG_LO16(ip) = (_s_)->__DECL_REG_LO16(ip); \
    (_d_)->cs = (_s_)->cs; \
    (_d_)->saved_upcall_mask = (_s_)->saved_upcall_mask; \
    (_d_)->__DECL_REG_LO16(flags) = (_s_)->__DECL_REG_LO16(flags); \
    (_d_)->__DECL_REG_LO16(sp) = (_s_)->__DECL_REG_LO16(sp); \
    (_d_)->ss = (_s_)->ss; \
    (_d_)->es = (_s_)->es; \
    (_d_)->ds = (_s_)->ds; \
    (_d_)->fs = (_s_)->fs; \
    (_d_)->gs = (_s_)->gs; \
} while (0)
