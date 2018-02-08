NAME=test-app
CC=bazel
SIM=22A695A4-B623-40CE-8E05-740891F9F8D8
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
	cp bazel-app/$(NAME).app $(SIM_APP)/
	xcrun simctl boot $(NAME)
	xcrun simctl install booted $(SIM_APP)/$(NAME).app

clean:
	rm -rf bazel-*
