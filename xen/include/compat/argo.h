#ifndef _COMPAT_ARGO_H
#define _COMPAT_ARGO_H
#include <xen/compat.h>
#include <public/argo.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)

typedef uint32_t compat_argo_port_t;

typedef uint64_t compat_argo_gfn_t;
typedef struct compat_argo_iov
{
    COMPAT_HANDLE(uint8) iov_hnd;
    uint32_t iov_len;
    uint32_t pad;
} compat_argo_iov_t;

typedef struct compat_argo_addr
{
    compat_argo_port_t aport;
    domid_compat_t domain_id;
    uint16_t pad;
} compat_argo_addr_t;

typedef struct compat_argo_send_addr
{
    struct xen_argo_addr src;
    struct xen_argo_addr dst;
} compat_argo_send_addr_t;

typedef struct compat_argo_ring
{

    uint32_t rx_ptr;

    uint32_t tx_ptr;

    uint8_t reserved[56];
    uint8_t ring[COMPAT_FLEX_ARRAY_DIM];
} compat_argo_ring_t;

typedef struct compat_argo_register_ring
{
    compat_argo_port_t aport;
    domid_compat_t partner_id;
    uint16_t pad;
    uint32_t len;
} compat_argo_register_ring_t;

typedef struct compat_argo_unregister_ring
{
    compat_argo_port_t aport;
    domid_compat_t partner_id;
    uint16_t pad;
} compat_argo_unregister_ring_t;
typedef struct compat_argo_ring_data_ent
{
    struct xen_argo_addr ring;
    uint16_t flags;
    uint16_t pad;
    uint32_t space_required;
    uint32_t max_message_size;
} compat_argo_ring_data_ent_t;

typedef struct compat_argo_ring_data
{
    uint32_t nent;
    uint32_t pad;
    struct xen_argo_ring_data_ent data[COMPAT_FLEX_ARRAY_DIM];
} compat_argo_ring_data_t;

struct compat_argo_ring_message_header
{
    uint32_t len;
    struct xen_argo_addr source;
    uint32_t message_type;
    uint8_t data[COMPAT_FLEX_ARRAY_DIM];
};
#pragma pack()
#endif /* _COMPAT_ARGO_H */
