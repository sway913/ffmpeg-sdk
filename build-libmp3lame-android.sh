#! /bin/sh
#
# build-libmp3lame-android.sh
# 
# Created by yuqilin on 11/29/2018
# Copyright (C) 2018 yuqilin <yuqilin1228@gmail.com>
#

echo ANDROID_NDK=$ANDROID_NDK

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FF_BUILD_ROOT=$BASE_DIR/android/build
FF_OUTPUT_ROOT=$BASE_DIR/android/output

LAME_ROOT=${BASE_DIR}/extra/libmp3lame

cd $LAME_ROOT/jni

$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk clean
$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk LOCAL_ARM_MODE=arm

# $ANDROID_NDK/ndk-build V=1 clean
# $ANDROID_NDK/ndk-build V=1 LOCAL_ARM_MODE=arm

HEADER_FILES=" \
    $LAME_ROOT/include/lame.h"

ARCHS="armv7a"

for ARCH in $ARCHS; do
    mkdir -p $FF_OUTPUT_ROOT/$ARCH/lame/include/lame
    mkdir -p $FF_OUTPUT_ROOT/$ARCH/lame/lib
    cp -a $HEADER_FILES $FF_OUTPUT_ROOT/$ARCH/lame/include/lame
done

# cp -a $LAME_ROOT/jni/obj/local/armeabi/libmp3lame.a $BUILD_ROOT/lame-armv5/lib

cp -a $LAME_ROOT/jni/obj/local/armeabi-v7a/libmp3lame.a $FF_OUTPUT_ROOT/armv7a/lame/lib
# cp -a $LAME_ROOT/jni/obj/local/arm64-v8a/libmp3lame.a $FF_OUTPUT_ROOT/arm64/lame/lib
