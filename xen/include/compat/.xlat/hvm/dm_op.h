
#define XLAT_dm_op_buf(_d_, _s_) do { \
    XLAT_dm_op_buf_HNDL_h(_d_, _s_); \
    (_d_)->size = (_s_)->size; \
} while (0)

#define CHECK_dm_op_relocate_memory \
    CHECK_SIZE_(struct, dm_op_relocate_memory); \
    CHECK_FIELD_(struct, dm_op_relocate_memory, size); \
    CHECK_FIELD_(struct, dm_op_relocate_memory, pad); \
    CHECK_FIELD_(struct, dm_op_relocate_memory, src_gfn); \
    CHECK_FIELD_(struct, dm_op_relocate_memory, dst_gfn)

#define CHECK_dm_op_create_ioreq_server \
    CHECK_SIZE_(struct, dm_op_create_ioreq_server); \
    CHECK_FIELD_(struct, dm_op_create_ioreq_server, handle_bufioreq); \
    CHECK_FIELD_(struct, dm_op_create_ioreq_server, pad); \
    CHECK_FIELD_(struct, dm_op_create_ioreq_server, id)

#define CHECK_dm_op_destroy_ioreq_server \
    CHECK_SIZE_(struct, dm_op_destroy_ioreq_server); \
    CHECK_FIELD_(struct, dm_op_destroy_ioreq_server, id); \
    CHECK_FIELD_(struct, dm_op_destroy_ioreq_server, pad)

#define CHECK_dm_op_get_ioreq_server_info \
    CHECK_SIZE_(struct, dm_op_get_ioreq_server_info); \
    CHECK_FIELD_(struct, dm_op_get_ioreq_server_info, id); \
    CHECK_FIELD_(struct, dm_op_get_ioreq_server_info, flags); \
    CHECK_FIELD_(struct, dm_op_get_ioreq_server_info, bufioreq_port); \
    CHECK_FIELD_(struct, dm_op_get_ioreq_server_info, ioreq_gfn); \
    CHECK_FIELD_(struct, dm_op_get_ioreq_server_info, bufioreq_gfn)

#define CHECK_dm_op_inject_event \
    CHECK_SIZE_(struct, dm_op_inject_event); \
    CHECK_FIELD_(struct, dm_op_inject_event, vcpuid); \
    CHECK_FIELD_(struct, dm_op_inject_event, vector); \
    CHECK_FIELD_(struct, dm_op_inject_event, type); \
    CHECK_FIELD_(struct, dm_op_inject_event, insn_len); \
    CHECK_FIELD_(struct, dm_op_inject_event, pad0); \
    CHECK_FIELD_(struct, dm_op_inject_event, error_code); \
    CHECK_FIELD_(struct, dm_op_inject_event, pad1); \
    CHECK_FIELD_(struct, dm_op_inject_event, cr2)

#define CHECK_dm_op_inject_msi \
    CHECK_SIZE_(struct, dm_op_inject_msi); \
    CHECK_FIELD_(struct, dm_op_inject_msi, data); \
    CHECK_FIELD_(struct, dm_op_inject_msi, pad); \
    CHECK_FIELD_(struct, dm_op_inject_msi, addr)

#define CHECK_dm_op_ioreq_server_range \
    CHECK_SIZE_(struct, dm_op_ioreq_server_range); \
    CHECK_FIELD_(struct, dm_op_ioreq_server_range, id); \
    CHECK_FIELD_(struct, dm_op_ioreq_server_range, pad); \
    CHECK_FIELD_(struct, dm_op_ioreq_server_range, type); \
    CHECK_FIELD_(struct, dm_op_ioreq_server_range, start); \
    CHECK_FIELD_(struct, dm_op_ioreq_server_range, end)

#define CHECK_dm_op_modified_memory \
    CHECK_SIZE_(struct, dm_op_modified_memory); \
    CHECK_FIELD_(struct, dm_op_modified_memory, nr_extents); \
    CHECK_FIELD_(struct, dm_op_modified_memory, opaque)

#define CHECK_dm_op_pin_memory_cacheattr \
    CHECK_SIZE_(struct, dm_op_pin_memory_cacheattr); \
    CHECK_FIELD_(struct, dm_op_pin_memory_cacheattr, start); \
    CHECK_FIELD_(struct, dm_op_pin_memory_cacheattr, end); \
    CHECK_FIELD_(struct, dm_op_pin_memory_cacheattr, type); \
    CHECK_FIELD_(struct, dm_op_pin_memory_cacheattr, pad)

#define CHECK_dm_op_remote_shutdown \
    CHECK_SIZE_(struct, dm_op_remote_shutdown); \
    CHECK_FIELD_(struct, dm_op_remote_shutdown, reason)

#define CHECK_dm_op_set_ioreq_server_state \
    CHECK_SIZE_(struct, dm_op_set_ioreq_server_state); \
    CHECK_FIELD_(struct, dm_op_set_ioreq_server_state, id); \
    CHECK_FIELD_(struct, dm_op_set_ioreq_server_state, enabled); \
    CHECK_FIELD_(struct, dm_op_set_ioreq_server_state, pad)

#define CHECK_dm_op_set_isa_irq_level \
    CHECK_SIZE_(struct, dm_op_set_isa_irq_level); \
    CHECK_FIELD_(struct, dm_op_set_isa_irq_level, isa_irq); \
    CHECK_FIELD_(struct, dm_op_set_isa_irq_level, level)

#define CHECK_dm_op_set_mem_type \
    CHECK_SIZE_(struct, dm_op_set_mem_type); \
    CHECK_FIELD_(struct, dm_op_set_mem_type, nr); \
    CHECK_FIELD_(struct, dm_op_set_mem_type, mem_type); \
    CHECK_FIELD_(struct, dm_op_set_mem_type, pad); \
    CHECK_FIELD_(struct, dm_op_set_mem_type, first_pfn)

#define CHECK_dm_op_set_pci_intx_level \
    CHECK_SIZE_(struct, dm_op_set_pci_intx_level); \
    CHECK_FIELD_(struct, dm_op_set_pci_intx_level, domain); \
    CHECK_FIELD_(struct, dm_op_set_pci_intx_level, bus); \
    CHECK_FIELD_(struct, dm_op_set_pci_intx_level, device); \
    CHECK_FIELD_(struct, dm_op_set_pci_intx_level, intx); \
    CHECK_FIELD_(struct, dm_op_set_pci_intx_level, level)

#define CHECK_dm_op_set_pci_link_route \
    CHECK_SIZE_(struct, dm_op_set_pci_link_route); \
    CHECK_FIELD_(struct, dm_op_set_pci_link_route, link); \
    CHECK_FIELD_(struct, dm_op_set_pci_link_route, isa_irq)

#define CHECK_dm_op_track_dirty_vram \
    CHECK_SIZE_(struct, dm_op_track_dirty_vram); \
    CHECK_FIELD_(struct, dm_op_track_dirty_vram, nr); \
    CHECK_FIELD_(struct, dm_op_track_dirty_vram, pad); \
    CHECK_FIELD_(struct, dm_op_track_dirty_vram, first_pfn)
