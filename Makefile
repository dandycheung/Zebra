ifeq ($(ROOTLESS),1)
	export ARCHS = arm64
	export TARGET = iphone:latest:14.0
	export INSTALL_PREFIX = /var/jb
	export DEB_ARCH = iphoneos-arm64
else
	export ARCHS = armv7 arm64
	export TARGET = iphone:latest:9.0
	export DEB_ARCH = iphoneos-arm
endif

INSTALL_TARGET_PROCESSES = Zebra

export ADDITIONAL_CFLAGS = -DINSTALL_PREFIX='"$(INSTALL_PREFIX)"' \
	-DDEB_ARCH='"$(DEB_ARCH)"'

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Zebra

Zebra_XCODEFLAGS = MARKETING_VERSION=$(THEOS_PACKAGE_BASE_VERSION) \
	INSTALL_PREFIX=$(INSTALL_PREFIX) \
	DEB_ARCH=$(DEB_ARCH) \
	CODE_SIGN_IDENTITY="" \
	AD_HOC_CODE_SIGNING_ALLOWED=YES
Zebra_CODESIGN_FLAGS = -SZebra/Zebra.entitlements
Zebra_INSTALL_PATH = $(INSTALL_PREFIX)/Applications

include $(THEOS_MAKE_PATH)/xcodeproj.mk

SUBPROJECTS = Firmware utils

include $(THEOS_MAKE_PATH)/aggregate.mk

ipa:
	+$(MAKE) PACKAGE_FORMAT=ipa package

before-package::
ifeq ($(ROOTLESS),1)
	sed -i s/iphoneos-arm/iphoneos-arm64/ $(THEOS_STAGING_DIR)/DEBIAN/control
endif

after-install::
	install.exec 'uiopen zbra:'
