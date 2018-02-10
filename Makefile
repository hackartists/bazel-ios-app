NAME=test
CC=$(shell which bazel)
CS=$(shell which codesign)
OUTBASE=.build
SIM=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$3}' | tr -d '()')
SIM_STAT=$(shell xcrun simctl list | grep 'iPhone X' | grep -v 'com.apple' | awk '{print $$4}' | tr -d '()')
SIM_APP=~/Library/Developer/CoreSimulator/Devices/$(SIM)/data/Containers/Bundle/Application
PROVISION=ios/org_artofthings_test.mobileprovision
ENT=$(shell find $(OUTBASE)/execroot -name "$(NAME)_entitlements.entitlements" )

all: clean ipa app codesign

build: ipa app

ipa:
	$(CC) --output_base=$(OUTBASE) build //ios:$(NAME) --ios_multi_cpus=armv7,arm64 --verbose_failures --sandbox_debug

app:
	rm -rf bazel-app
	mkdir -p bazel-app
	cp -rf bazel-bin/ios/$(NAME).ipa bazel-app/
	cp -rf $(ENT) bazel-app/
	cd bazel-app && unzip $(NAME).ipa
	mv  bazel-app/payload/$(NAME).app bazel-app/
	rm -rf bazel-app/$(NAME).ipa bazel-app/payload bazel-app/SwiftSupport

simulate: sim-boot sim-install

codesign:
	$(CS) --force --sign $(shell security cms -D -i "$(PROVISION)" > tmp.cert && /usr/libexec/PlistBuddy -c 'Print DeveloperCertificates:0' tmp.cert | openssl x509 -inform DER -noout -fingerprint | cut -d= -f2 | sed -e s#:##g && rm -rf tmp.cert ) --entitlements bazel-app/$(NAME)_entitlements.entitlements bazel-app/$(NAME).app

deploy:
	ios-deploy --bundle bazel-app/$(NAME).app

debug:
	ios-deploy --debug --bundle bazel-app/$(NAME).app

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
