XEN_ROOT = $(CURDIR)/../../..
include $(XEN_ROOT)/tools/Rules.mk

SUBDIRS= \
	mmap \
	xentoollog \
	eventchn xc \
	xb xs xl

.PHONY: all
all: subdirs-all

.PHONY: install
install: subdirs-install

.PHONY: uninstall
uninstall: subdirs-uninstall

.PHONY: clean
clean: subdirs-clean

.PHONY: distclean
distclean: subdirs-distclean
