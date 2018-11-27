#! /bin/sh
#
# build-ffmpeg-android.sh
# 
# Created by yuqilin on 11/24/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

# export BUILD_ARCHS="armv7a arm64 x86 x86_64"
export BUILD_ARCHS="armv7a arm64"

. ./init-android.sh

cd android

for ARCH in $BUILD_ARCHS; do

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH start"
    echo "--------------------"

    echo FF_BUILD_ROOT=$FF_BUILD_ROOT
    sh ./do-compile-ffmpeg.sh $ARCH

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH finish"
    echo "--------------------"
done

