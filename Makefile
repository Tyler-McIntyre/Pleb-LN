.PHONY: help devices run quick emulator build clean

help:
	@echo "pleb-ln Flutter Development Commands"
	@echo "====================================="
	@echo ""
	@echo "Device & Emulator Management:"
	@echo "  make devices       - List all available devices/emulators"
	@echo "  make emulator      - Launch Android emulator"
	@echo "  make run           - Run app on available device (with hot reload)"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build         - Build debug APK"
	@echo "  make clean         - Clean build artifacts"
	@echo ""
	@echo "Quick Development:"
	@echo "  make quick         - Launch emulator + Run app"

devices:
	flutter devices

emulator:
	flutter emulators --launch Pixel_4_API_31

run:
	flutter run

build:
	flutter build apk --debug

clean:
	flutter clean

quick:
	@echo "Starting pleb-ln development..."
	flutter emulators --launch Pixel_4_API_31 &
	@echo "Waiting for emulator to start..."
	sleep 15
	@echo "Running pleb-ln app..."
	flutter run
