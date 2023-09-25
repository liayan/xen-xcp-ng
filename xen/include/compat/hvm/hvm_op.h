#ifndef _COMPAT_HVM_HVM_OP_H
#define _COMPAT_HVM_HVM_OP_H
#include <xen/compat.h>
#include <public/hvm/hvm_op.h>
#pragma pack(4)
#include "../xen.h"
#pragma pack(4)
#include "../trace.h"
#pragma pack(4)
#include "../event_channel.h"
#pragma pack(4)

struct compat_hvm_param {
    domid_compat_t domid;
    uint32_t index;
    uint64_t value;
};
typedef struct compat_hvm_param compat_hvm_param_t;
DEFINE_COMPAT_HANDLE(compat_hvm_param_t);

struct compat_hvm_altp2m_suppress_ve {
    uint16_t view;
    uint8_t suppress_ve;
    uint8_t pad1;
    uint32_t pad2;
    uint64_t gfn;
};
struct compat_hvm_pagetable_dying {

    domid_compat_t domid;
    uint16_t pad[3];

    uint64_t gpa;
};
typedef struct compat_hvm_pagetable_dying compat_hvm_pagetable_dying_t;
DEFINE_COMPAT_HANDLE(compat_hvm_pagetable_dying_t);

struct compat_hvm_get_time {
    uint64_t now;
};
typedef struct compat_hvm_get_time compat_hvm_get_time_t;
DEFINE_COMPAT_HANDLE(compat_hvm_get_time_t);

struct compat_hvm_xentrace {
    uint16_t event, extra_bytes;
    uint8_t extra[TRACE_EXTRA_MAX * sizeof(uint32_t)];
};
typedef struct compat_hvm_xentrace compat_hvm_xentrace_t;
DEFINE_COMPAT_HANDLE(compat_hvm_xentrace_t);
struct compat_hvm_get_mem_type {

    domid_compat_t domid;

    uint16_t mem_type;
    uint16_t pad[2];

    uint64_t pfn;
};
typedef struct compat_hvm_get_mem_type compat_hvm_get_mem_type_t;
DEFINE_COMPAT_HANDLE(compat_hvm_get_mem_type_t);
struct compat_hvm_evtchn_upcall_vector {
    uint32_t vcpu;
    uint8_t vector;
};
typedef struct compat_hvm_evtchn_upcall_vector compat_hvm_evtchn_upcall_vector_t;
DEFINE_COMPAT_HANDLE(compat_hvm_evtchn_upcall_vector_t);
struct compat_hvm_altp2m_domain_state {

    uint8_t state;
};
typedef struct compat_hvm_altp2m_domain_state compat_hvm_altp2m_domain_state_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_domain_state_t);

struct compat_hvm_altp2m_vcpu_enable_notify {
    uint32_t vcpu_id;
    uint32_t pad;

    uint64_t gfn;
};
typedef struct compat_hvm_altp2m_vcpu_enable_notify compat_hvm_altp2m_vcpu_enable_notify_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_vcpu_enable_notify_t);

struct compat_hvm_altp2m_vcpu_disable_notify {
    uint32_t vcpu_id;
};
typedef struct compat_hvm_altp2m_vcpu_disable_notify compat_hvm_altp2m_vcpu_disable_notify_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_vcpu_disable_notify_t);

struct compat_hvm_altp2m_view {

    uint16_t view;

    uint16_t hvmmem_default_access;
};
typedef struct compat_hvm_altp2m_view compat_hvm_altp2m_view_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_view_t);
struct compat_hvm_altp2m_mem_access {

    uint16_t view;

    uint16_t access;
    uint32_t pad;

    uint64_t gfn;
};
typedef struct compat_hvm_altp2m_mem_access compat_hvm_altp2m_mem_access_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_mem_access_t);

struct compat_hvm_altp2m_set_mem_access_multi {

    uint16_t view;
    uint16_t pad;

    uint32_t nr;

    uint64_t opaque;

    COMPAT_HANDLE(const_uint64) pfn_list;

    COMPAT_HANDLE(const_uint8) access_list;
};

struct compat_hvm_altp2m_change_gfn {

    uint16_t view;
    uint16_t pad1;
    uint32_t pad2;

    uint64_t old_gfn;

    uint64_t new_gfn;
};
typedef struct compat_hvm_altp2m_change_gfn compat_hvm_altp2m_change_gfn_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_change_gfn_t);

struct compat_hvm_altp2m_get_vcpu_p2m_idx {
    uint32_t vcpu_id;
    uint16_t altp2m_idx;
};

struct compat_hvm_altp2m_op {
    uint32_t version;
    uint32_t cmd;
    domid_compat_t domain;
    uint16_t pad1;
    uint32_t pad2;
    union {
        struct compat_hvm_altp2m_domain_state domain_state;
        struct compat_hvm_altp2m_vcpu_enable_notify enable_notify;
        struct compat_hvm_altp2m_view view;

        struct compat_hvm_altp2m_mem_access mem_access;
        struct compat_hvm_altp2m_change_gfn change_gfn;
        struct compat_hvm_altp2m_set_mem_access_multi set_mem_access_multi;
        struct compat_hvm_altp2m_suppress_ve suppress_ve;
        struct compat_hvm_altp2m_vcpu_disable_notify disable_notify;
        struct compat_hvm_altp2m_get_vcpu_p2m_idx get_vcpu_p2m_idx;
        uint8_t pad[64];
    } u;
};
typedef struct compat_hvm_altp2m_op compat_hvm_altp2m_op_t;
DEFINE_COMPAT_HANDLE(compat_hvm_altp2m_op_t);
#pragma pack()
#endif /* _COMPAT_HVM_HVM_OP_H */
