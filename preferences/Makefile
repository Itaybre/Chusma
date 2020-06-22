TARGET = iphone:13.3:12.0

export GO_EASY_ON_ME=1

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Chusma

Chusma_FILES = IBCRootListController.m
Chusma_INSTALL_PATH = /Library/PreferenceBundles
Chusma_FRAMEWORKS = UIKit
Chusma_PRIVATE_FRAMEWORKS = Preferences
Chusma_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
Chusma_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Chusma.plist$(ECHO_END)
