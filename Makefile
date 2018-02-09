NAME=test-app
CC=bazel
SIM=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$3}' | tr -d '()')
SIM_STAT=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$4}' | tr -d '()')
SIM_APP=~/Library/Developer/CoreSimulator/Devices/$(SIM)/data/Containers/Bundle/Application

all: clean ipa app

build: ipa app

ipa:
	$(CC) build //ios:$(NAME)

app:
	mkdir -p bazel-app
	cp -rf bazel-bin/ios/$(NAME).ipa bazel-app/
	cd bazel-app && unzip $(NAME).ipa
	mv -rf bazel-app/payload/$(NAME).app bazel-app/
	rm -rf bazel-app/$(NAME).ipa bazel-app/payload bazel-app/SwiftSupport

simulate: sim-boot sim-install

sim-boot:
ifeq ($(SIM_STAT),Shutdown)
	xcrun simctl boot $(SIM)
	sleep 2
endif

sim-shutdown:
ifeq ($(SIM_STAT),Booted)
	xcrun simctl shutdown $(SIM)
	sleep 2
endif

sim-install:
	cp -rf bazel-app/$(NAME).app $(SIM_APP)/
	xcrun simctl install $(SIM) $(SIM_APP)/$(NAME).app
	open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

clean: sim-shutdown
	rm -rf bazel-*
