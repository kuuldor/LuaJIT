#!/bin/bash

DEST_DIR=`pwd`/../lib/android
DEST_LIB_DIR=$DEST_DIR/lib
DEST_INC_DIR=$DEST_DIR/include

if [ ! -e $DEST_DIR ]; then
	mkdir -p $DEST_DIR
fi

DISABLE_JIT_FLAG="-DLUAJIT_DISABLE_JIT"

EXTRA_LUA_JIT_CFLAG="$DISABLE_JIT_FLAG"

BUILD_TARGET=amalg

#android-x86
make clean
NDK=~/Library/Android/sdk/ndk-bundle/
NDKABI=17
NDKTRIPLE=x86
NDKVER=$NDK/toolchains/$NDKTRIPLE-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/i686-linux-android-
NDKF="-isystem $NDK/sysroot/usr/include/i686-linux-android -D__ANDROID_API__=$NDKABI -D_FILE_OFFSET_BITS=32"
NDK_SYSROOT_BUILD=$NDK/sysroot
NDK_SYSROOT_LINK=$NDK/platforms/android-$NDKABI/arch-x86

make HOST_CC="gcc -m32" CFLAGS="$EXTRA_LUA_JIT_CFLAG" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux TARGET_CFLAGS="--sysroot $NDK_SYSROOT_BUILD" $BUILD_TARGET

mkdir -p $DEST_LIB_DIR/x86/
mv ./src/libluajit.a "$DEST_LIB_DIR/x86/libluajit.a"
# mv ./src/libluajit.so "$DEST_LIB_DIR/x86/libluajit.so"


#android-armeabi
make clean
NDK=~/Library/Android/sdk/ndk-bundle/
NDKABI=17
NDKTRIPLE=arm-linux-androideabi
NDKVER=$NDK/toolchains/$NDKTRIPLE-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/$NDKTRIPLE-
NDKF="-isystem $NDK/sysroot/usr/include/$NDKTRIPLE -D__ANDROID_API__=$NDKABI -D_FILE_OFFSET_BITS=32"
NDK_SYSROOT_BUILD=$NDK/sysroot
NDK_SYSROOT_LINK=$NDK/platforms/android-$NDKABI/arch-arm

make HOST_CC="gcc -m32" CFLAGS="$EXTRA_LUA_JIT_CFLAG" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux TARGET_CFLAGS="--sysroot $NDK_SYSROOT_BUILD" $BUILD_TARGET

mkdir -p $DEST_LIB_DIR/armeabi/
mv ./src/libluajit.a "$DEST_LIB_DIR/armeabi/libluajit.a"
# mv ./src/libluajit.so "$DEST_LIB_DIR/armeabi/libluajit.so"


#android-armeabi-v7a
make clean
NDK=~/Library/Android/sdk/ndk-bundle/
NDKABI=17
NDKTRIPLE=arm-linux-androideabi
NDKVER=$NDK/toolchains/$NDKTRIPLE-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/$NDKTRIPLE-
NDKF="-isystem $NDK/sysroot/usr/include/$NDKTRIPLE -D__ANDROID_API__=$NDKABI -D_FILE_OFFSET_BITS=32"
NDK_SYSROOT_BUILD=$NDK/sysroot
NDK_SYSROOT_LINK=$NDK/platforms/android-$NDKABI/arch-arm
NDKARCH="-march=armv7-a -mfloat-abi=softfp"
make HOST_CC="gcc -m32" CFLAGS="$EXTRA_LUA_JIT_CFLAG" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux TARGET_CFLAGS="--sysroot $NDK_SYSROOT_BUILD" $BUILD_TARGET

mkdir -p $DEST_LIB_DIR/armeabi-v7a/
mv ./src/libluajit.a "$DEST_LIB_DIR/armeabi-v7a/libluajit.a"
# mv ./src/libluajit.so "$DEST_LIB_DIR/armeabi-v7a/libluajit.so"


#android-arm64-v8a
make clean

NDK=~/Library/Android/sdk/ndk-bundle
NDKABI=21
NDKTRIPLE=aarch64-linux-android
NDKVER=$NDK/toolchains/$NDKTRIPLE-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/$NDKTRIPLE-
NDKF="-isystem $NDK/sysroot/usr/include/$NDKTRIPLE -D__ANDROID_API__=$NDKABI"
NDK_SYSROOT_BUILD=$NDK/sysroot
NDK_SYSROOT_LINK=$NDK/platforms/android-$NDKABI/arch-arm64

make HOST_CC="gcc" CFLAGS="$EXTRA_LUA_JIT_CFLAG" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux TARGET_CFLAGS="--sysroot $NDK_SYSROOT_BUILD" $BUILD_TARGET

mkdir -p $DEST_LIB_DIR/arm64-v8a/
mv ./src/libluajit.a "$DEST_LIB_DIR/arm64-v8a/libluajit.a"
# mv ./src/libluajit.so "$DEST_LIB_DIR/arm64-v8a/libluajit.so"


#android-x86_64
make clean
NDK=~/Library/Android/sdk/ndk-bundle/
NDKABI=21
NDKTRIPLE=x86_64
NDKVER=$NDK/toolchains/$NDKTRIPLE-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/x86_64-linux-android-
NDKF="-isystem $NDK/sysroot/usr/include/x86_64-linux-android -D__ANDROID_API__=$NDKABI"
NDK_SYSROOT_BUILD=$NDK/sysroot
NDK_SYSROOT_LINK=$NDK/platforms/android-$NDKABI/arch-x86_64

make HOST_CC="gcc" CFLAGS="$EXTRA_LUA_JIT_CFLAG -DLUAJIT_ENABLE_GC64" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux TARGET_CFLAGS="--sysroot $NDK_SYSROOT_BUILD" $BUILD_TARGET

mkdir -p $DEST_LIB_DIR/x86_64/
mv ./src/libluajit.a "$DEST_LIB_DIR/x86_64/libluajit.a"
# mv ./src/libluajit.so "$DEST_LIB_DIR/x86_64/libluajit.so"


mkdir -p $DEST_INC_DIR/
cp ./src/lua*.h ./src/lauxlib.h "$DEST_INC_DIR/"

make clean
