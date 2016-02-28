
#!/bin/bash

rm -rf ./build

mkdir -p ./build/Production

#xcodebuild -target F4SDK ONLY_ACTIVE_ARCH=NO  -sdk iphoneos  BUILD_DIR=./build clean build
#xcodebuild -target F4SDK -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR=./build  clean build

xcodebuild -workspace F4SDK.xcworkspace -scheme F4SDK -sdk iphoneos  BUILD_DIR=./build clean build
xcodebuild -workspace F4SDK.xcworkspace -scheme F4SDK -sdk iphonesimulator  BUILD_DIR=./build clean build

lipo -create -output ./build/Production/libF4SDK.a ./build/Debug-iphoneos/libF4SDK.a ./build/Debug-iphonesimulator/libF4SDK.a
cp -r ./build/Debug-iphoneos/include ./build/Production/
