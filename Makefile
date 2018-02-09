NAME=test-app
CC=bazel
SIM=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$3}' | tr -d '()')
SIM_STAT=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$4}' | tr -d '()')
SIM_APP=~/Library/Developer/CoreSimulator/Devices/$(SIM)/data/Containers/Bundle/Application

all: clean ipa app

ipa:
	$(CC) build //ios:$(NAME)

app:
	mkdir bazel-app
	cp bazel-bin/ios/$(NAME).ipa bazel-app/
	cd bazel-app && unzip $(NAME).ipa
	mv bazel-app/payload/$(NAME).app bazel-app/
	rm -rf bazel-app/$(NAME).ipa bazel-app/payload bazel-app/SwiftSupport

simulate:
ifeq ($(SIM_STAT),Shutdown)
	xcrun simctl boot $(SIM)
endif
	cp -rf bazel-app/$(NAME).app $(SIM_APP)/
	xcrun simctl install booted $(SIM_APP)/$(NAME).app
	open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

clean:
	rm -rf bazel-*
ifeq ($(SIM_STAT),Booted)
	xcrun simctl shutdown $(SIM)
endif
