obj-y += avc.o
obj-y += hooks.o
obj-y += flask_op.o

subdir-y += ss

CFLAGS += -I./include

AWK = awk

FLASK_H_DEPEND = policy/security_classes policy/initial_sids
AV_H_DEPEND = policy/access_vectors

FLASK_H_FILES = include/flask.h include/class_to_string.h include/initial_sid_to_string.h
AV_H_FILES = include/av_perm_to_string.h include/av_permissions.h
ALL_H_FILES = $(FLASK_H_FILES) $(AV_H_FILES)

$(obj-y) ss/built_in.o: $(ALL_H_FILES)

$(subst include/,%/,$(FLASK_H_FILES)): $(FLASK_H_DEPEND)
	$(SHELL) policy/mkflask.sh $(AWK) include $(FLASK_H_DEPEND)

$(subst include/,%/,$(AV_H_FILES)): $(AV_H_DEPEND)
	$(SHELL) policy/mkaccess_vector.sh $(AWK) $(AV_H_DEPEND)

obj-bin-$(CONFIG_XSM_FLASK_POLICY) += flask-policy.o
flask-policy.o: policy.bin

FLASK_BUILD_DIR := $(CURDIR)
POLICY_SRC := $(FLASK_BUILD_DIR)/xenpolicy-$(XEN_FULLVERSION)

policy.bin: FORCE
	$(MAKE) -f $(XEN_ROOT)/tools/flask/policy/Makefile.common -C $(XEN_ROOT)/tools/flask/policy FLASK_BUILD_DIR=$(FLASK_BUILD_DIR)
	cmp -s $(POLICY_SRC) $@ || cp $(POLICY_SRC) $@

.PHONY: clean
clean::
	rm -f $(ALL_H_FILES) *.o $(DEPS_RM) policy.* $(POLICY_SRC)
