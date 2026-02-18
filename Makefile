APP_NAME = Please
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: build bundle run install clean lint format format-check

build:
	swift build -c release

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(MACOS_DIR)
	mkdir -p $(RESOURCES_DIR)
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	cp Sources/Please/Resources/Info.plist $(CONTENTS_DIR)/Info.plist
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
	rm -rf $(APP_BUNDLE)

lint:
	swiftlint lint --config .swiftlint.yml Sources/

format:
	swiftformat Sources/ --config .swiftformat

format-check:
	swiftformat Sources/ --config .swiftformat --lint
