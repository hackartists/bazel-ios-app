NAME=test
CC=$(shell which bazel)
CS=$(shell which codesign)
BUILDS= debug.build release.build
DEBUG=debug
RELEASE=release
OUTPUT_BASE=.build
OUTPUT_PATH=output
ifeq ("$(SIMULATOR)","")
	SIMM=iPhoneX\(
else
	SIMM=$(shell echo $(SIMULATOR) | tr -d ' ')\(
endif
ifeq ("$(PROVISION)","")
	PROVISION=default.mobileprovision
endif
SIM=$(shell xcrun simctl list devices | tr -d ' ' | grep $(SIMM) | awk -F "[()]" '{for(i=2;i<NF;i+=2) print $$i}' | grep '^[-A-Z,0-9]*$$')
SIM_STAT=$(shell xcrun simctl list devices | tr -d ' ' | grep $(SIMM) | grep -v 'com.apple' | awk -F "[()]" '{for(i=2;i<NF;i+=2) print $$i}' |  grep -e 'Shutdown' -e 'Booted')
SIM_APP=~/Library/Developer/CoreSimulator/Devices/$(SIM)/data/Containers/Bundle/Application

all: $(BUILDS)

debug.build: debug.ipa $(NAME)_debug.app
	rm -rf $(OUTPUT_PATH)/$(DEBUG)
	mkdir -p $(OUTPUT_PATH)/$(DEBUG)
	mv bazel-* $(OUTPUT_PATH)/$(DEBUG)/

release.build: release.ipa $(NAME)_release.app codesign
	rm -rf $(OUTPUT_PATH)/$(RELEASE)
	mkdir -p $(OUTPUT_PATH)/$(RELEASE)
	mv bazel-* $(OUTPUT_PATH)/$(RELEASE)/


debug.ipa:
	$(CC) --output_base=$(OUTPUT_BASE)/$(DEBUG) build //ios:$(NAME)

%.app:
	rm -rf bazel-app
	mkdir -p bazel-app
	cp -rf bazel-bin/ios/$(NAME).ipa bazel-app/$(NAME).ipa
	cp -rf bazel-bin/ios/$(NAME)_entitlements.entitlements bazel-app/
	cd bazel-app && unzip $(NAME).ipa
	mv  bazel-app/payload/$(NAME).app bazel-app/$@
	rm -rf bazel-app/$(NAME).ipa bazel-app/payload bazel-app/SwiftSupport

release.ipa:
	$(CC) --output_base=$(OUTPUT_BASE)/$(RELEASE) build //ios:$(NAME) --ios_multi_cpus=arm64

codesign:
	$(CS) --force --sign $(shell security cms -D -i "$(PROVISION)" > tmp.cert && /usr/libexec/PlistBuddy -c 'Print DeveloperCertificates:0' tmp.cert | openssl x509 -inform DER -noout -fingerprint | cut -d= -f2 | sed -e s#:##g && rm -rf tmp.cert ) --entitlements bazel-app/$(NAME)_entitlements.entitlements bazel-app/$(NAME)_release.app bazel-app/$(NAME)_release.app/Frameworks/*

deploy:
	ios-deploy --bundle $(OUTPUT_PATH)/$(RELEASE)/bazel-app/$(NAME)_$(RELEASE).app

debug:
	ios-deploy --debug --bundle $(OUTPUT_PATH)/$(RELEASE)/bazel-app/$(NAME)_$(RELEASE).app

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
	cp -rf $(OUTPUT_PATH)/$(DEBUG)/bazel-app/$(NAME)_$(DEBUG).app $(SIM_APP)/
	xcrun simctl install $(SIM) $(SIM_APP)/$(NAME)_$(DEBUG).app
	open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

clean:
	rm -rf output
	sudo rm -rf .build
