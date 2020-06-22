TARGET = iphone:13.3:12.0

export GO_EASY_ON_ME=1
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Chusma

Chusma_FILES = Tweak.xm ChusmaBulletinProvider.x
Chusma_CFLAGS = -fobjc-arc
Chusma_PRIVATE_FRAMEWORKS = AppSupport BulletinBoard
Chusma_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += app
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
