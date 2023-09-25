
#define CHECK_argo_addr \
    CHECK_SIZE_(struct, argo_addr); \
    CHECK_FIELD_(struct, argo_addr, aport); \
    CHECK_FIELD_(struct, argo_addr, domain_id); \
    CHECK_FIELD_(struct, argo_addr, pad)

#define XLAT_argo_iov(_d_, _s_) do { \
    XLAT_argo_iov_HNDL_iov_hnd(_d_, _s_); \
    (_d_)->iov_len = (_s_)->iov_len; \
    (_d_)->pad = (_s_)->pad; \
} while (0)

#define CHECK_argo_register_ring \
    CHECK_SIZE_(struct, argo_register_ring); \
    CHECK_FIELD_(struct, argo_register_ring, aport); \
    CHECK_FIELD_(struct, argo_register_ring, partner_id); \
    CHECK_FIELD_(struct, argo_register_ring, pad); \
    CHECK_FIELD_(struct, argo_register_ring, len)

#define CHECK_argo_ring \
    CHECK_SIZE_(struct, argo_ring); \
    CHECK_FIELD_(struct, argo_ring, rx_ptr); \
    CHECK_FIELD_(struct, argo_ring, tx_ptr); \
    CHECK_FIELD_(struct, argo_ring, reserved); \
    CHECK_FIELD_(struct, argo_ring, ring)

#define CHECK_argo_ring_data \
    CHECK_SIZE_(struct, argo_ring_data); \
    CHECK_FIELD_(struct, argo_ring_data, nent); \
    CHECK_FIELD_(struct, argo_ring_data, pad); \
    CHECK_argo_ring_data_ent

#define CHECK_argo_ring_data_ent \
    CHECK_SIZE_(struct, argo_ring_data_ent); \
    CHECK_argo_addr; \
    CHECK_FIELD_(struct, argo_ring_data_ent, flags); \
    CHECK_FIELD_(struct, argo_ring_data_ent, pad); \
    CHECK_FIELD_(struct, argo_ring_data_ent, space_required); \
    CHECK_FIELD_(struct, argo_ring_data_ent, max_message_size)

#define CHECK_argo_ring_message_header \
    CHECK_SIZE_(struct, argo_ring_message_header); \
    CHECK_FIELD_(struct, argo_ring_message_header, len); \
    CHECK_argo_addr; \
    CHECK_FIELD_(struct, argo_ring_message_header, message_type); \
    CHECK_FIELD_(struct, argo_ring_message_header, data)

#define CHECK_argo_send_addr \
    CHECK_SIZE_(struct, argo_send_addr); \
    CHECK_argo_addr; \
    CHECK_argo_addr

#define CHECK_argo_unregister_ring \
    CHECK_SIZE_(struct, argo_unregister_ring); \
    CHECK_FIELD_(struct, argo_unregister_ring, aport); \
    CHECK_FIELD_(struct, argo_unregister_ring, partner_id); \
    CHECK_FIELD_(struct, argo_unregister_ring, pad)
