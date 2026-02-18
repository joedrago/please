APP_NAME = Please
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

.PHONY: build bundle run clean lint format format-check

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
	-pkill -x $(APP_NAME)
	open $(APP_BUNDLE)

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)

lint:
	swiftlint lint --config .swiftlint.yml Sources/

format:
	swiftformat Sources/ --config .swiftformat

format-check:
	swiftformat Sources/ --config .swiftformat --lint
