
#define CHECK_vcpu_hvm_context \
    CHECK_SIZE_(struct, vcpu_hvm_context); \
    CHECK_FIELD_(struct, vcpu_hvm_context, mode); \
    CHECK_FIELD_(struct, vcpu_hvm_context, pad); \
    CHECK_vcpu_hvm_x86_32; \
    CHECK_vcpu_hvm_x86_64

#define CHECK_vcpu_hvm_x86_32 \
    CHECK_SIZE_(struct, vcpu_hvm_x86_32); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, eax); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ecx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, edx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ebx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, esp); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ebp); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, esi); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, edi); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, eip); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, eflags); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cr0); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cr3); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cr4); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, pad1); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, efer); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cs_base); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ds_base); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ss_base); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, es_base); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, tr_base); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cs_limit); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ds_limit); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ss_limit); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, es_limit); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, tr_limit); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, cs_ar); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ds_ar); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, ss_ar); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, es_ar); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, tr_ar); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_32, pad2)

#define CHECK_vcpu_hvm_x86_64 \
    CHECK_SIZE_(struct, vcpu_hvm_x86_64); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rax); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rcx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rdx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rbx); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rsp); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rbp); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rsi); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rdi); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rip); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, rflags); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, cr0); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, cr3); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, cr4); \
    CHECK_FIELD_(struct, vcpu_hvm_x86_64, efer)
