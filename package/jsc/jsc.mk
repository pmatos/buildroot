################################################################################
#
# jsc
#
################################################################################

JSC_VERSION = 5d863eb4e193c80576bd30e1dfb9b70ea7c50f6c
JSC_SITE = $(call github,WebKit,webkit,$(JSC_VERSION))
JSC_INSTALL_STAGING = YES
JSC_DEPENDENCIES = host-bison host-cmake host-flex host-gperf host-ruby icu pcre

JSC_BUILD_JSC_ARGS = --jsc-only
JSC_CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=${BR2_HOST_DIR}/usr/share/buildroot/toolchainfile.cmake


ifeq ($(BR2_PACKAGE_JSC_DEBUG),y)
JSC_BUILD_JSC_ARGS += --debug
JSC_BUILD_DIR_NAME = Debug
JSC_CMAKE_ARGS += \
        -DENABLE_STATIC_JSC=ON \
	-DCMAKE_C_FLAGS_DEBUG='-g -O0' \
	-DCMAKE_CXX_FLAGS_DEBUG='-g -O0'
else
JSC_BUILD_JSC_ARGS += --release
JSC_BUILD_DIR_NAME = Release
JSC_CMAKE_ARGS += \
        -DENABLE_STATIC_JSC=ON \
	-DCMAKE_C_FLAGS_RELEASE='-O2 -g -DNDEBUG' \
	-DCMAKE_CXX_FLAGS_RELEASE='-O2 -g -DNDEBUG'
endif
JSC_MAKE_ARGS=

ifneq ($(BR2_JLEVEL),0)
	JSC_MAKE_ARGS +="-j${BR2_JLEVEL}"
endif

ifneq ($(strip $(JSC_MAKE_ARGS)),)
JSC_BUILD_JSC_ARGS += \
			  --makeargs="$(JSC_MAKE_ARGS)"
endif

JSC_BUILD_JSC_ARGS += \
			  --cmakeargs="$(JSC_CMAKE_ARGS)"
define JSC_BUILD_CMDS
	(pushd $(@D) && \
	PATH="${BR2_HOST_DIR}/ccache:${BR2_HOST_DIR}/usr/bin:${PATH}" ./Tools/Scripts/build-jsc ${JSC_BUILD_JSC_ARGS} && \
    popd)
endef

define JSC_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/bin/jsc $(STAGING_DIR)/usr/bin/jsc
	if [ -e $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/lib/libJavaScriptCore.so ]; then \
	  cp -d $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/lib/libJavaScriptCore.so* $(STAGING_DIR)/usr/lib/ ; \
	fi
endef

define JSC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/bin/jsc $(TARGET_DIR)/usr/bin/jsc
	$(STRIPCMD) $(TARGET_DIR)/usr/bin/jsc
	if [ -e $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/lib/libJavaScriptCore.so ]; then \
	  cp -d $(@D)/WebKitBuild/$(JSC_BUILD_DIR_NAME)/lib/libJavaScriptCore.so* $(TARGET_DIR)/usr/lib/ ; \
	  $(STRIPCMD) $(TARGET_DIR)/usr/lib/libJavaScriptCore.so.1.0.* ; \
	fi
endef


$(eval $(generic-package))
