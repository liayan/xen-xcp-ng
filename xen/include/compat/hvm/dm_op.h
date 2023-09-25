#ifndef _COMPAT_HVM_DM_OP_H
#define _COMPAT_HVM_DM_OP_H
#include <xen/compat.h>
#include <public/hvm/dm_op.h>
#pragma pack(4)
#include "../xen.h"
#pragma pack(4)
#include "../event_channel.h"
#pragma pack(4)
typedef uint16_t ioservid_compat_t;
struct compat_dm_op_create_ioreq_server {

    uint8_t handle_bufioreq;
    uint8_t pad[3];

    ioservid_compat_t id;
};
struct compat_dm_op_get_ioreq_server_info {

    ioservid_compat_t id;

    uint16_t flags;

    evtchn_port_compat_t bufioreq_port;

    uint64_t ioreq_gfn;

    uint64_t bufioreq_gfn;
};
struct compat_dm_op_ioreq_server_range {

    ioservid_compat_t id;
    uint16_t pad;

    uint32_t type;

    uint64_t start, end;
};
struct compat_dm_op_set_ioreq_server_state {

    ioservid_compat_t id;

    uint8_t enabled;
    uint8_t pad;
};
struct compat_dm_op_destroy_ioreq_server {

    ioservid_compat_t id;
    uint16_t pad;
};
struct compat_dm_op_track_dirty_vram {

    uint32_t nr;
    uint32_t pad;

    uint64_t first_pfn;
};

struct compat_dm_op_set_pci_intx_level {

    uint16_t domain;
    uint8_t bus, device, intx;

    uint8_t level;
};

struct compat_dm_op_set_isa_irq_level {

    uint8_t isa_irq;

    uint8_t level;
};

struct compat_dm_op_set_pci_link_route {

    uint8_t link;

    uint8_t isa_irq;
};
struct compat_dm_op_modified_memory {

    uint32_t nr_extents;

    uint32_t opaque;
};

struct compat_dm_op_modified_memory_extent {

    uint32_t nr;
    uint32_t pad;

    uint64_t first_pfn;
};
struct compat_dm_op_set_mem_type {

    uint32_t nr;

    uint16_t mem_type;
    uint16_t pad;

    uint64_t first_pfn;
};
struct compat_dm_op_inject_event {

    uint32_t vcpuid;

    uint8_t vector;

    uint8_t type;
    uint8_t insn_len;
    uint8_t pad0;

    uint32_t error_code;
    uint32_t pad1;

    uint64_t cr2;
};

struct compat_dm_op_inject_msi {

    uint32_t data;
    uint32_t pad;

    uint64_t addr;
};
struct compat_dm_op_map_mem_type_to_ioreq_server {
    ioservid_compat_t id;
    uint16_t type;
    uint32_t flags;

    uint64_t opaque;

};

struct compat_dm_op_remote_shutdown {
    uint32_t reason;

};
struct compat_dm_op_relocate_memory {

    uint32_t size;
    uint32_t pad;

    uint64_t src_gfn;

    uint64_t dst_gfn;
};

struct compat_dm_op_pin_memory_cacheattr {
    uint64_t start;
    uint64_t end;
    uint32_t type;
    uint32_t pad;
};

struct compat_dm_op {
    uint32_t op;
    uint32_t pad;
    union {
        struct xen_dm_op_create_ioreq_server create_ioreq_server;
        struct xen_dm_op_get_ioreq_server_info get_ioreq_server_info;
        struct xen_dm_op_ioreq_server_range map_io_range_to_ioreq_server;
        struct xen_dm_op_ioreq_server_range unmap_io_range_from_ioreq_server;
        struct xen_dm_op_set_ioreq_server_state set_ioreq_server_state;
        struct xen_dm_op_destroy_ioreq_server destroy_ioreq_server;
        struct xen_dm_op_track_dirty_vram track_dirty_vram;
        struct xen_dm_op_set_pci_intx_level set_pci_intx_level;
        struct xen_dm_op_set_isa_irq_level set_isa_irq_level;
        struct xen_dm_op_set_pci_link_route set_pci_link_route;
        struct xen_dm_op_modified_memory modified_memory;
        struct xen_dm_op_set_mem_type set_mem_type;
        struct xen_dm_op_inject_event inject_event;
        struct xen_dm_op_inject_msi inject_msi;
        struct compat_dm_op_map_mem_type_to_ioreq_server
                map_mem_type_to_ioreq_server;
        struct xen_dm_op_remote_shutdown remote_shutdown;
        struct xen_dm_op_relocate_memory relocate_memory;
        struct xen_dm_op_pin_memory_cacheattr pin_memory_cacheattr;
    } u;
};

struct compat_dm_op_buf {
    COMPAT_HANDLE(void) h;
    compat_ulong_t size;
};
typedef struct compat_dm_op_buf compat_dm_op_buf_t;
DEFINE_COMPAT_HANDLE(compat_dm_op_buf_t);
#pragma pack()
#endif /* _COMPAT_HVM_DM_OP_H */
