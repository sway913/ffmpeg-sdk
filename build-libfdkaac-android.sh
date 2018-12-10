#! /bin/sh
#
# build-libfdkaac-android.sh
# 
# Created by yuqilin on 11/30/2018
# Copyright (C) 2018 yuqilin <yuqilin1228@gmail.com>
#

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT=$BASE_DIR/android/build
OUTPUT_ROOT=$BASE_DIR/android/output

FDKAAC_ROOT=${BASE_DIR}/extra/fdk-aac

cd $FDKAAC_ROOT

$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk clean
$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk LOCAL_ARM_MODE=arm

HEADER_FILES=" \
    $FDKAAC_ROOT/libAACdec/include/aacdecoder_lib.h \
    $FDKAAC_ROOT/libAACenc/include/aacenc_lib.h \
    $FDKAAC_ROOT/libSYS/include/FDK_audio.h \
    $FDKAAC_ROOT/libSYS/include/genericStds.h \
    $FDKAAC_ROOT/libSYS/include/machine_type.h"

ARCHS="armv7a arm64"

for ARCH in $ARCHS; do
    mkdir -p $OUTPUT_ROOT/$ARCH/fdk-aac/include/fdk-aac
    mkdir -p $OUTPUT_ROOT/$ARCH/fdk-aac/lib
    cp -a $HEADER_FILES $OUTPUT_ROOT/$ARCH/fdk-aac/include/fdk-aac
done

# cp -a $FDKAAC_ROOT/obj/local/armeabi/libfdkaac.a $BUILD_ROOT/armeabi/install/lib
cp -a $FDKAAC_ROOT/obj/local/armeabi-v7a/libfdkaac.a $OUTPUT_ROOT/armv7a/fdk-aac/lib
cp -a $FDKAAC_ROOT/obj/local/arm64-v8a/libfdkaac.a $OUTPUT_ROOT/arm64/fdk-aac/lib

