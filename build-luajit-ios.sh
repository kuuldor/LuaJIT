#/bin/sh

#if [[ "$#" -eq 0 ]]; then
	#echo "Usage: $0 SDKVERSION"
	#exit
#fi

SDKVER=$1

LIB_DIR=`pwd`/../lib
DEST_BIN_DIR=$LIB_DIR/bin
DEST_DIR=$LIB_DIR/ios
DEST_LIB_DIR=$DEST_DIR/lib
DEST_INC_DIR=$DEST_DIR/include

DISABLE_JIT_FLAG="-DLUAJIT_DISABLE_JIT"
#EXTRA_LUA_JIT_CFLAG="$DISABLE_JIT_FLAG"

BUILD_TARGET=amalg

if [ ! -e $DEST_DIR ]; then
	mkdir -p $DEST_DIR
fi

if [ ! -e $DEST_BIN_DIR ]; then
	mkdir -p $DEST_BIN_DIR
fi

if [ ! -e $DEST_LIB_DIR ]; then
	mkdir -p $DEST_LIB_DIR
fi

# Check if the binary exists.
if [ -f "$DEST_LIB_DIR/libluajit.a" ]; then
	rm -f $DEST_LIB_DIR/libluajit.a
fi

rm -rf $DEST_DIR/temp
mkdir -p $DEST_DIR/temp

XCODE_PATH=`xcode-select -print-path`

# Build for MacOS (x86_64) 32-bit
make clean
make CFLAGS="${EXTRA_LUA_JIT_CFLAG}" 
mv src/luajit $DEST_BIN_DIR/luajit-32

# Build for MacOS (x86_64) 64-bit
make clean
make CFLAGS="${EXTRA_LUA_JIT_CFLAG} -DLUAJIT_ENABLE_GC64"
mv src/luajit $DEST_BIN_DIR/luajit-64


BUILD_TARGET=amalgslib

# Build for iOS device (armv7)
SDK_PATH=$XCODE_PATH/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDKVER}.sdk
TC_PATH=$XCODE_PATH/Toolchains/XcodeDefault.xctoolchain/usr/bin/
TARGET_FLAGS="-arch armv7 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make DEFAULT_CC="cc" CFLAGS="-DLUAJIT_DISABLE_JIT"  HOST_CC="cc -m32 -arch i386" CROSS=$TC_PATH TARGET_FLAGS="$TARGET_FLAGS" \
     TARGET_SYS=iOS  $BUILD_TARGET
mv src/libluajit.a $DEST_DIR/temp/libluajit-ios-armv7.a

# Build for iOS device (arm64)
TARGET_FLAGS="-arch arm64 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make DEFAULT_CC="cc" CFLAGS="-DLUAJIT_DISABLE_JIT"  HOST_CC="cc " CROSS=$TC_PATH TARGET=arm64 TARGET_FLAGS="$TARGET_FLAGS" \
     TARGET_SYS=iOS  $BUILD_TARGET
mv src/libluajit.a $DEST_DIR/temp/libluajit-ios-arm64.a

# Build for iOS simulator
SDK_PATH=$XCODE_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDKVER}.sdk
TARGET_FLAGS="-arch x86_64 -isysroot $SDK_PATH -miphoneos-version-min=9.0 -fembed-bitcode"
make clean
make  DEFAULT_CC="cc" CFLAGS="-DLJ_NO_SYSTEM=1 -DLUAJIT_ENABLE_GC64 -DLUAJIT_DISABLE_JIT" HOST_CFLAGS="-arch x86_64" \
	HOST_LDFLAGS="-arch x86_64" TARGET_SYS=iOS TARGET=x86_64 CROSS=$TC_PATH TARGET_FLAGS="$TARGET_FLAGS"  $BUILD_TARGET
mv src/libluajit.a $DEST_DIR/temp/libluajit-simulator.a

# Combine all archives to one.
libtool -o $DEST_LIB_DIR/libluajit.a $DEST_DIR/temp/*.a 2> /dev/null

mkdir -p $DEST_INC_DIR
cp ./src/lua*.h ./src/lauxlib.h "$DEST_INC_DIR/"

make clean
rm -rf $DEST_DIR/temp/
