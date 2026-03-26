APP_NAME = Dimmer
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app

.PHONY: build bundle icon clean

build:
	swift build -c release

icon:
	swift scripts/make_icon.swift
	iconutil -c icns AppIcon.iconset -o AppIcon.icns

bundle: build icon
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/
	cp AppIcon.icns $(APP_BUNDLE)/Contents/Resources/

clean:
	rm -rf $(APP_BUNDLE) .build AppIcon.iconset AppIcon.icns
