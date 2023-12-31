-include $(XEN_ROOT)/config/Paths.mk

CONFIG_RUMP         := n
ifeq ($(CONFIG_RUMP),y)
XEN_OS              := NetBSDRump
endif

# Tools path
BISON               := 
FLEX                := 
PYTHON              := python
PYTHON_PATH         := /usr/bin/python
PY_NOOPT_CFLAGS     := -O1
PERL                := /usr/bin/perl
AS86                := /usr/bin/as86
LD86                := /usr/bin/ld86
BCC                 := /usr/bin/bcc
IASL                := /usr/bin/iasl
AWK                 := /usr/bin/awk
FETCHER             := /usr/bin/wget -c -O

# Extra folder for libs/includes
PREPEND_INCLUDES    := 
PREPEND_LIB         := 
APPEND_INCLUDES     := 
APPEND_LIB          := 

PTHREAD_CFLAGS      := -pthread
PTHREAD_LDFLAGS     := -pthread
PTHREAD_LIBS        := 

PTYFUNCS_LIBS       := -lutil

LIBNL3_LIBS         := 
LIBNL3_CFLAGS       := 
XEN_TOOLS_RPATH     := n

# Download GIT repositories via HTTP or GIT's own protocol?
# GIT's protocol is faster and more robust, when it works at all (firewalls
# may block it). We make it the default, but if your GIT repository downloads
# fail or hang, please pass --enable-githttp to configure.
GIT_HTTP            ?= n

# Optional components
XENSTAT_XENTOP      := y
OCAML_TOOLS         := y
FLASK_POLICY        := n
CONFIG_OVMF         := n
CONFIG_ROMBIOS      := y
CONFIG_SEABIOS      := n
CONFIG_IPXE         := n
CONFIG_QEMU_TRAD    := n
CONFIG_QEMU_XEN     := n
CONFIG_QEMUU_EXTRA_ARGS:= 
CONFIG_LIBNL        := n

CONFIG_SYSTEMD      := y
SYSTEMD_CFLAGS      :=  
SYSTEMD_LIBS        := -lsystemd  
XEN_SYSTEMD_DIR     := $(prefix)/lib/systemd/system/
XEN_SYSTEMD_MODULES_LOAD := $(prefix)/lib/modules-load.d/
CONFIG_9PFS         := 

LINUX_BACKEND_MODULES := xen-evtchn xen-gntdev xen-gntalloc xen-blkback xen-netback xen-pciback evtchn gntdev netbk blkbk xen-scsibk usbbk pciback xen-acpi-processor

#System options
ZLIB                :=  -DHAVE_BZLIB -lbz2 -DHAVE_LZMA -llzma -DHAVE_LZO1X -llzo2
CONFIG_LIBICONV     := n
EXTFS_LIBS          := -lext2fs
CURSES_LIBS         := -lncurses
TINFO_LIBS          := -ltinfo
ARGP_LDFLAGS        := 

FILE_OFFSET_BITS    := 

CONFIG_PV_SHIM      := n
