#! /bin/sh
#
# build-ffmpeg-android.sh
# 
# Created by yuqilin on 11/24/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

# export BUILD_ARCHS="armv7a arm64 x86 x86_64"
BUILD_ARCHS="armv7a arm64"

. ./init-android.sh

./init-config.sh

# for transcode
cp config/module-transcode.sh config/module.sh

./build-libmp3lame-android.sh

cd android

for ARCH in $BUILD_ARCHS; do

    echo "--------------------"
    echo "[*] build libx264 for $ARCH start"
    echo "--------------------"

    sh ./do-compile-libx264.sh $ARCH

    echo "--------------------"
    echo "[*] build libx264 for $ARCH finish"
    echo "--------------------"

    sh ./do-compile-libfdkaac.sh $ARCH

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH start"
    echo "--------------------"

    echo FF_BUILD_ROOT=$FF_BUILD_ROOT

    sh ./do-compile-ffmpeg.sh $ARCH

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH finish"
    echo "--------------------"
done

