deps_config := \
	Kconfig.debug \
	drivers/video/Kconfig \
	drivers/pci/Kconfig \
	drivers/passthrough/Kconfig \
	drivers/cpufreq/Kconfig \
	drivers/char/Kconfig \
	drivers/acpi/Kconfig \
	drivers/Kconfig \
	common/Kconfig \
	arch/Kconfig \
	arch/x86/Kconfig \
	Kconfig

include/config/auto.conf: \
	$(deps_config)

ifneq "$(XEN_CONFIG_EXPERT)" "y"
include/config/auto.conf: FORCE
endif
ifneq "$(XEN_FULLVERSION)" "4.13.5"
include/config/auto.conf: FORCE
endif
ifneq "$(XEN_HAS_CHECKPOLICY)" "n"
include/config/auto.conf: FORCE
endif
ifneq "$(XEN_HAS_BUILD_ID)" "y"
include/config/auto.conf: FORCE
endif
ifneq "$(ARCH)" "x86_64"
include/config/auto.conf: FORCE
endif
ifneq "$(SRCARCH)" "x86"
include/config/auto.conf: FORCE
endif

$(deps_config): ;
