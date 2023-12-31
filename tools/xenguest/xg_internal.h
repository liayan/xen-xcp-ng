#ifndef __XG_INTERNAL_H__
#define __XG_INTERNAL_H__

#include <assert.h>
#include <inttypes.h>
#include <string.h>
#include <sys/time.h>

#include <xenctrl.h>
#include <xenguest.h>

#include <xc_bitops.h>

#define ASSERT(x) assert(x)

#define __printf(f, v) __attribute__((format(__printf__, f, v)))

enum xenguest_mode {
    XG_MODE_SAVE,
    XG_MODE_HVM_SAVE,
    XG_MODE_RESTORE,
    XG_MODE_HVM_RESTORE,
    XG_MODE_RESUME_SLOW,
    XG_MODE_LINUX_BUILD,
    XG_MODE_HVM_BUILD,
    XG_MODE_TEST,
    XG_MODE_LISTEN,
    XG_MODE_PVH_BUILD,
    XG_MODE__END__,
};

void xg_err(const char *msg, ...) __printf(1, 2);
void xg_info(const char *msg, ...) __printf(1, 2);

typedef struct xs_handle xs_handle;

extern xc_interface *xch;
extern xs_handle *xsh;
extern int domid;
extern bool force;
extern int opt_flags;
extern bool opt_vgpu;

struct pvh_module {
    char *filename;
    char *cmdline;
};

typedef struct pvh_module pvh_module;

/* Read and write /local/domain/$domid/ relative paths. */
char *xenstore_getsv(const char *fmt, va_list ap);
char *xenstore_gets(const char *fmt, ...)  __printf(1, 2);
uint64_t xenstore_get(const char *fmt, ...) __printf(1, 2);
int xenstore_putsv(const char *key, const char *fmt, ...) __printf(2, 3);
int xenstore_puts(const char *key, const char *val);

int stub_xc_linux_build(int c_mem_max_mib, int mem_start_mib,
                        const char *image_name, const char *ramdisk_name,
                        const char *cmdline, const char *features,
                        int flags, int store_evtchn, int store_domid,
                        int console_evtchn, int console_domid,
                        unsigned long *store_mfn, unsigned long *console_mfn,
                        char *protocol);
int stub_xc_hvm_build(int mem_max_mib, int mem_start_mib,
                      const char *image_name, const char *cmdline,
                      const pvh_module *modules, int nmodules,
                      const char *features, int flags,
                      int store_evtchn, int store_domid,
                      int console_evtchn, int console_domid,
                      unsigned long *store_mfn, unsigned long *console_mfn,
                      bool is_pvh);
int stub_xc_domain_save(int fd, int flags);
int emu_stub_xc_domain_save(int fd, void *data, int flags);

int stub_xc_domain_restore(int fd, int store_evtchn, int console_evtchn,
                           int hvm,
                           unsigned long *store_mfn, unsigned long *console_mfn);
int stub_xc_domain_resume_slow(void);

int suspend_callback(void *data);
int emu_suspend_callback(void *data);

void setup_legacy_conversion(int opt_fd, enum xenguest_mode mode);
void cleanup_legacy_conversion(void);

extern char *xs_domain_path;
extern char *pci_passthrough_sbdf_list;

/* Calcluate the difference between two timevals, in microseconds. */
static inline uint64_t tv_delta_us(const struct timeval *new,
                                   const struct timeval *old)
{
    return (((new->tv_sec - old->tv_sec)*1000000) +
            (new->tv_usec - old->tv_usec));
}

/* Calcluate the difference between two timespecs, in microseconds. */
static inline uint64_t ts_delta_us(const struct timespec *new,
                                   const struct timespec *old)
{
    return (((new->tv_sec - old->tv_sec)*1000000) +
            ((new->tv_nsec - old->tv_nsec)/1000));
}

/* Seconds and milliseconds expressed as microseconds. */
#define SEC(s)  ((s) * 1000ull * 1000)
#define MSEC(s) ((s) * 1000ull)

int xenguest_precopy_policy(struct precopy_stats stats, void *user);
void emp_do_listen(void);
void send_emu_progress(unsigned long done, unsigned long total);

#endif

/*
 * Local variables:
 * mode: C
 * c-file-style: "BSD"
 * c-basic-offset: 4
 * tab-width: 4
 * indent-tabs-mode: nil
 * End:
 */
