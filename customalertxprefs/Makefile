include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CustomAlertXprefs
CustomAlertXprefs_FILES = ionRootListController.m
CustomAlertXprefs_INSTALL_PATH = /Library/PreferenceBundles
CustomAlertXprefs_FRAMEWORKS = UIKit
CustomAlertXprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomAlertXprefs.plist$(ECHO_END)
