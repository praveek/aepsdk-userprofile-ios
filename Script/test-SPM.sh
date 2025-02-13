#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=TestProject

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the package.
swift package init

# Create the Package.swift.
echo "// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: \"TestProject\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: \"TestProject\",
            targets: [\"TestProject\"]
        )
    ],
    dependencies: [
        .package(name: \"AEPCore\", url: \"https://github.com/adobe/aepsdk-core-ios.git\", .branch(\"main\")),
        .package(name: \"AEPUserProfile\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"TestProject\",
            dependencies: [
                .product(name: \"AEPCore\", package: \"AEPCore\"),
                .product(name: \"AEPIdentity\", package: \"AEPCore\"),
                .product(name: \"AEPLifecycle\", package: \"AEPCore\"),
                .product(name: \"AEPServices\", package: \"AEPCore\"),
                .product(name: \"AEPSignal\", package: \"AEPCore\"),
                .product(name: \"AEPUserProfile\", package: \"AEPUserProfile\"),
                ])
    ]
)
" >Package.swift

swift package update
swift package resolve

# This is necessary to avoid internal PIF error
swift package dump-pif > /dev/null
(xcodebuild clean -scheme TestProject -destination 'generic/platform=iOS' > /dev/null) || :

# Archive for generic iOS device
echo '############# Archive for generic iOS device ###############'
xcodebuild archive -scheme TestProject -destination 'generic/platform=iOS'

# Build for generic iOS device
echo '############# Build for generic iOS device ###############'
xcodebuild build -scheme TestProject -destination 'generic/platform=iOS'

# Build for x86_64 simulator
echo '############# Build for x86_64 simulator ###############'
xcodebuild build -scheme TestProject -destination 'generic/platform=iOS Simulator' ARCHS=x86_64

# Clean up.
cd ../
rm -rf $PROJECT_NAME
