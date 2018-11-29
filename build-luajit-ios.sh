#/bin/sh

#if [[ "$#" -eq 0 ]]; then
	#echo "Usage: $0 SDKVERSION"
	#exit
#fi

SDKVER=$1

# Check if the binary exists.
if [ -f "../lib/libluajit.a" ]; then
	rm -f ../lib/libluajit.a
fi

rm -rf ../lib/temp
mkdir -p ../lib/temp

XCODE_PATH=`xcode-select -print-path`

# Build for MacOS (x86_64) 32-bit
make clean
make
mv src/luajit ../lib/luajit-32

# Build for MacOS (x86_64) 64-bit
make clean
make CFLAGS=-DLUAJIT_ENABLE_GC64
mv src/luajit ../lib/luajit-64

# Build for iOS device (armv7)
SDK_PATH=$XCODE_PATH/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDKVER}.sdk
TC_PATH=$XCODE_PATH/Toolchains/XcodeDefault.xctoolchain/usr/bin/
TARGET_FLAGS="-arch armv7 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make DEFAULT_CC="cc" HOST_CC="cc -m32 -arch i386" CROSS=$TC_PATH TARGET_FLAGS="$TARGET_FLAGS" \
     TARGET_SYS=iOS
mv src/libluajit.a ../lib/temp/libluajit-ios-armv7.a

# Build for iOS device (arm64)
TARGET_FLAGS="-arch arm64 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make DEFAULT_CC="cc"  HOST_CC="cc " CROSS=$TC_PATH TARGET=arm64 TARGET_FLAGS="$TARGET_FLAGS" \
     TARGET_SYS=iOS
mv src/libluajit.a ../lib/temp/libluajit-ios-arm64.a

# Build for iOS simulator
SDK_PATH=$XCODE_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDKVER}.sdk
TARGET_FLAGS="-arch x86_64 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make  DEFAULT_CC="cc" CFLAGS="-DLJ_NO_SYSTEM=1 -DLUAJIT_ENABLE_GC64" HOST_CFLAGS="-arch x86_64" HOST_LDFLAGS="-arch x86_64" TARGET_SYS=iOS TARGET=x86_64 CROSS=$TC_PATH TARGET_FLAGS="$TARGET_FLAGS" 
mv src/libluajit.a ../lib/temp/libluajit-simulator.a

# Combine all archives to one.
libtool -o ../lib/libluajit.a ../lib/temp/*.a 2> /dev/null
make clean
rm -rf ../lib/temp
