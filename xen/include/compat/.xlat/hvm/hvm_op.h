
#define XLAT_hvm_altp2m_set_mem_access_multi(_d_, _s_) do { \
    (_d_)->view = (_s_)->view; \
    (_d_)->pad = (_s_)->pad; \
    (_d_)->nr = (_s_)->nr; \
    (_d_)->opaque = (_s_)->opaque; \
    XLAT_hvm_altp2m_set_mem_access_multi_HNDL_pfn_list(_d_, _s_); \
    XLAT_hvm_altp2m_set_mem_access_multi_HNDL_access_list(_d_, _s_); \
} while (0)
