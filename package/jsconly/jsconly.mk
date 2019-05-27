################################################################################
#
# jsconly
#
################################################################################

JSCONLY_VERSION = 5d863eb4e193c80576bd30e1dfb9b70ea7c50f6c
JSCONLY_SITE = $(call github,WebKit,webkit,$(JSCONLY_VERSION))
JSCONLY_INSTALL_STAGING = YES
JSCONLY_DEPENDENCIES = host-bison host-cmake host-flex host-gperf host-ruby icu pcre

JSCONLY_BUILD_JSC_ARGS = --jsc-only
JSCONLY_CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=${BR2_HOST_DIR}/usr/share/buildroot/toolchainfile.cmake


ifeq ($(BR2_PACKAGE_JSC_DEBUG),y)
JSCONLY_BUILD_JSC_ARGS += --debug
JSCONLY_BUILD_DIR_NAME = Debug
JSCONLY_CMAKE_ARGS += \
        -DENABLE_STATIC_JSC=ON \
	-DCMAKE_C_FLAGS_DEBUG='-g -O0' \
	-DCMAKE_CXX_FLAGS_DEBUG='-g -O0'
else
JSCONLY_BUILD_JSC_ARGS += --release
JSCONLY_BUILD_DIR_NAME = Release
JSCONLY_CMAKE_ARGS += \
        -DENABLE_STATIC_JSC=ON \
	-DCMAKE_C_FLAGS_RELEASE='-O2 -g -DNDEBUG' \
	-DCMAKE_CXX_FLAGS_RELEASE='-O2 -g -DNDEBUG'
endif
JSCONLY_MAKE_ARGS=

ifneq ($(BR2_JLEVEL),0)
	JSCONLY_MAKE_ARGS +="-j${BR2_JLEVEL}"
endif

ifneq ($(strip $(JSCONLY_MAKE_ARGS)),)
JSCONLY_BUILD_JSC_ARGS += \
			  --makeargs="$(JSCONLY_MAKE_ARGS)"
endif

JSCONLY_BUILD_JSC_ARGS += \
			  --cmakeargs="$(JSCONLY_CMAKE_ARGS)"
define JSCONLY_BUILD_CMDS
	(pushd $(@D) && \
	PATH="${BR2_HOST_DIR}/ccache:${BR2_HOST_DIR}/usr/bin:${PATH}" ./Tools/Scripts/build-jsc ${JSCONLY_BUILD_JSC_ARGS} && \
    popd)
endef

define JSCONLY_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/bin/jsc $(STAGING_DIR)/usr/bin/jsc
	if [ -e $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/lib/libJavaScriptCore.so ]; then \
	  cp -d $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/lib/libJavaScriptCore.so* $(STAGING_DIR)/usr/lib/ ; \
	fi
endef

define JSCONLY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/bin/jsc $(TARGET_DIR)/usr/bin/jsc
	$(STRIPCMD) $(TARGET_DIR)/usr/bin/jsc
	if [ -e $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/lib/libJavaScriptCore.so ]; then \
	  cp -d $(@D)/WebKitBuild/$(JSCONLY_BUILD_DIR_NAME)/lib/libJavaScriptCore.so* $(TARGET_DIR)/usr/lib/ ; \
	  $(STRIPCMD) $(TARGET_DIR)/usr/lib/libJavaScriptCore.so.1.0.* ; \
	fi
endef


$(eval $(generic-package))
