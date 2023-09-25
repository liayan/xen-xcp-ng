// found ocaml type x86_arch_emulation_flags at xenctrl.ml:38
BUILD_BUG_ON( XEN_X86_EMU_LAPIC              != (1u << 0)  );
BUILD_BUG_ON( XEN_X86_EMU_HPET               != (1u << 1)  );
BUILD_BUG_ON( XEN_X86_EMU_PM                 != (1u << 2)  );
BUILD_BUG_ON( XEN_X86_EMU_RTC                != (1u << 3)  );
BUILD_BUG_ON( XEN_X86_EMU_IOAPIC             != (1u << 4)  );
BUILD_BUG_ON( XEN_X86_EMU_PIC                != (1u << 5)  );
BUILD_BUG_ON( XEN_X86_EMU_VGA                != (1u << 6)  );
BUILD_BUG_ON( XEN_X86_EMU_IOMMU              != (1u << 7)  );
BUILD_BUG_ON( XEN_X86_EMU_PIT                != (1u << 8)  );
BUILD_BUG_ON( XEN_X86_EMU_USE_PIRQ           != (1u << 9)  );
BUILD_BUG_ON( XEN_X86_EMU_VPCI               != (1u << 10) );
BUILD_BUG_ON( XEN_X86_EMU_ALL                != (1u << 11)-1u );
// found ocaml type domain_create_flag at xenctrl.ml:60
BUILD_BUG_ON( XEN_DOMCTL_CDF_hvm             != (1u << 0)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_hap             != (1u << 1)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_s3_integrity    != (1u << 2)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_oos_off         != (1u << 3)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_xs_domain       != (1u << 4)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_iommu           != (1u << 5)  );
BUILD_BUG_ON( XEN_DOMCTL_CDF_MAX             != (1u << 5)  );
// found ocaml type domain_create_iommu_opts at xenctrl.ml:68
BUILD_BUG_ON( XEN_DOMCTL_IOMMU_no_sharept    != (1u << 0)  );
BUILD_BUG_ON( XEN_DOMCTL_IOMMU_MAX           != (1u << 0)  );
// found ocaml type physinfo_cap_flag at xenctrl.ml:123
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_hvm         != (1u << 0)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_pv          != (1u << 1)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_directio    != (1u << 2)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_hap         != (1u << 3)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_shadow      != (1u << 4)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_iommu_hap_pt_share != (1u << 5)  );
BUILD_BUG_ON( XEN_SYSCTL_PHYSCAP_MAX         != (1u << 5)  );
