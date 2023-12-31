/*
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation;
 * version 2.1 of the License.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; If not, see <http://www.gnu.org/licenses/>.
 */

#include <errno.h>
#include <unistd.h>
#include <stdlib.h>

#include "private.h"

static int all_restrict_cb(Xentoolcore__Active_Handle *ah, domid_t domid) {
    xenevtchn_handle *xce = CONTAINER_OF(ah, *xce, tc_ah);

    if (xce->fd < 0)
        /* just in case */
        return 0;

    return xenevtchn_restrict(xce, domid);
}

static xenevtchn_handle *xenevtchn_alloc_handle(xentoollog_logger *logger)
{
    xenevtchn_handle *xce = malloc(sizeof(*xce));

    if (!xce) return NULL;

    xce->fd = -1;
    xce->logger = logger;
    xce->logger_tofree  = NULL;

    xce->tc_ah.restrict_callback = all_restrict_cb;
    xentoolcore__register_active_handle(&xce->tc_ah);

    if (!xce->logger) {
        xce->logger = xce->logger_tofree =
            (xentoollog_logger*)
            xtl_createlogger_stdiostream(stderr, XTL_PROGRESS, 0);
        if (!xce->logger) goto err;
    }

    return xce;

 err:
    xenevtchn_close(xce);
    return NULL;
}

xenevtchn_handle *xenevtchn_open(xentoollog_logger *logger, unsigned int flags)
{
    xenevtchn_handle *xce;
    int rc;

    if ( flags & ~XENEVTCHN_NO_CLOEXEC )
    {
        errno = EINVAL;
        return NULL;
    }

    xce = xenevtchn_alloc_handle(logger);
    if ( !xce )
        return NULL;

    rc = osdep_evtchn_open(xce, flags);
    if ( rc  < 0 ) goto err;

    return xce;

err:
    xenevtchn_close(xce);
    return NULL;
}

xenevtchn_handle *xenevtchn_fdopen(struct xentoollog_logger *logger,
                                   int fd, unsigned int flags)
{
    xenevtchn_handle *xce;

    if ( flags )
    {
        errno = EINVAL;
        return NULL;
    }

    xce = xenevtchn_alloc_handle(logger);
    if ( !xce )
        return NULL;

    xce->fd = fd;

    return xce;
}

int xenevtchn_close(xenevtchn_handle *xce)
{
    int rc;

    if ( !xce )
        return 0;

    xentoolcore__deregister_active_handle(&xce->tc_ah);
    rc = osdep_evtchn_close(xce);
    xtl_logger_destroy(xce->logger_tofree);
    free(xce);
    return rc;
}

int xenevtchn_restrict(xenevtchn_handle *xce, domid_t domid)
{
    return osdep_evtchn_restrict(xce, domid);
}

/*
 * Local variables:
 * mode: C
 * c-file-style: "BSD"
 * c-basic-offset: 4
 * tab-width: 4
 * indent-tabs-mode: nil
 * End:
 */
