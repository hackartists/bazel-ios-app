package(default_visibility=["//visibility:public"])

licenses(["notice"])

load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name="src",
    srcs=[
        "src/AppDelegate.swift",
    ],
)

ios_application(
    name="test",
    app_icons=["//res:PhoneAppIcon.xcassets"],
    bundle_id="org.artofthings.test",
    provisioning_profile="org_artofthings_test.mobileprovision",
    families=[
        "iphone",
        "ipad",
    ],
    infoplists=[":Info.plist"],
    minimum_os_version="8.0",
    deps=[":src"],
)
