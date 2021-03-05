include /opt/theos/makefiles/common.mk

BUNDLE_NAME = CustomAlertX
CustomAlertX_FILES = ioncaRootListController.m
CustomAlertX_INSTALL_PATH = /Library/PreferenceBundles
CustomAlertX_FRAMEWORKS = UIKit
CustomAlertX_PRIVATE_FRAMEWORKS = Preferences

include /opt/theos/makefiles/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomAlertX.plist$(ECHO_END)
