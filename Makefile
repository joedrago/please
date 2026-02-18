APP_NAME = Please
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

# Code signing / notarization
DEVELOPER_ID ?= $(shell cat ~/.appledevid 2>/dev/null)
NOTARY_PROFILE ?= please-notary
VERSION := $(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Sources/Please/Resources/Info.plist)
DMG_NAME = $(APP_NAME)-$(VERSION).dmg
VENV_DIR = .venv
DMGBUILD = $(VENV_DIR)/bin/dmgbuild

define check_developer_id
	@if [ -z "$(DEVELOPER_ID)" ]; then \
		echo "Error: DEVELOPER_ID not set. Either:"; \
		echo "  1. Create ~/.appledevid containing your identity, e.g.:"; \
		echo '     echo "Developer ID Application: Your Name (TEAMID)" > ~/.appledevid'; \
		echo "  2. Pass it on the command line:"; \
		echo '     make dmg DEVELOPER_ID="Developer ID Application: Your Name (TEAMID)"'; \
		exit 1; \
	fi
endef

.PHONY: build bundle run install clean lint format format-check icon sign notarize dmg venv

build:
	swift build -c release

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(MACOS_DIR)
	mkdir -p $(RESOURCES_DIR)
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Sources/Please/Resources/Info.plist $(CONTENTS_DIR)/Info.plist
	cp Sources/Please/Resources/AppIcon.icns $(RESOURCES_DIR)/AppIcon.icns
	@echo "Built $(APP_BUNDLE)"

all: bundle

run: bundle
	-pkill -x $(APP_NAME) && while pgrep -x $(APP_NAME) >/dev/null; do sleep 0.1; done
	open $(APP_BUNDLE)

install: bundle
	-pkill -x $(APP_NAME) && while pgrep -x $(APP_NAME) >/dev/null; do sleep 0.1; done
	rm -rf /Applications/$(APP_BUNDLE)
	cp -a $(APP_BUNDLE) /Applications/$(APP_BUNDLE)
	open /Applications/$(APP_BUNDLE)

clean:
	swift package clean
	rm -rf $(APP_BUNDLE) $(VENV_DIR) *.dmg *.zip

lint:
	swiftlint lint --config .swiftlint.yml Sources/

format:
	swiftformat Sources/ --config .swiftformat

format-check:
	swiftformat Sources/ --config .swiftformat --lint

icon:
	swift scripts/generate-icon.swift
	bash scripts/generate-icns.sh

venv: $(DMGBUILD)

$(DMGBUILD):
	python3 -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --quiet dmgbuild

sign: bundle
	$(check_developer_id)
	codesign --deep --force --verify --verbose \
		--sign "$(DEVELOPER_ID)" \
		--options runtime --timestamp \
		$(APP_BUNDLE)

notarize: sign
	rm -f $(APP_NAME).zip
	ditto -c -k --keepParent $(APP_BUNDLE) $(APP_NAME).zip
	xcrun notarytool submit $(APP_NAME).zip \
		--keychain-profile "$(NOTARY_PROFILE)" --wait
	rm -f $(APP_NAME).zip
	xcrun stapler staple $(APP_BUNDLE)

dmg: notarize $(DMGBUILD)
	rm -f $(DMG_NAME)
	$(DMGBUILD) -s scripts/dmgbuildSettings.py \
		-D app=$(APP_BUNDLE) \
		"$(APP_NAME)" $(DMG_NAME)
	codesign --force --sign "$(DEVELOPER_ID)" $(DMG_NAME)
	xcrun notarytool submit $(DMG_NAME) \
		--keychain-profile "$(NOTARY_PROFILE)" --wait
	xcrun stapler staple $(DMG_NAME)
	@echo "Created and notarized $(DMG_NAME)"
