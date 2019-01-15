#! /bin/sh
#
# build-ffmpeg-android.sh
# 
# Created by yuqilin on 11/24/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

# TODO：
# 编译命令能支持指定指令集，主要是mp3lame

# 提示：fdkaac使用autogen编译，需安装autoconf，automake

# export BUILD_ARCHS="armv7a arm64 x86 x86_64"
# BUILD_ARCHS="armv7a"

. ./init-android.sh

./init-config.sh

# # for transcode
cp config/module-transcode.sh config/module.sh

./build-libmp3lame-android.sh

./build-libfdkaac-android.sh

cd android

for ARCH in $BUILD_ARCHS; do

    echo "--------------------"
    echo "[*] build libx264 for $ARCH start"
    echo "--------------------"

    sh ./do-compile-libx264.sh $ARCH

    # echo "--------------------"
    # echo "[*] build libfdkaac for $ARCH finish"
    # echo "--------------------"

    # sh ./do-compile-libfdkaac.sh $ARCH

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH start"
    echo "--------------------"

    echo FF_BUILD_ROOT=$FF_BUILD_ROOT

    sh ./do-compile-ffmpeg.sh $ARCH

    echo "--------------------"
    echo "[*] build ffmpeg for $ARCH finish"
    echo "--------------------"
done

mkdir -p ./android/ffmpeginvoke/src/main/jniLibs/armeabi-v7a/

cp $FF_OUTPUT_ROOT/armv7a/ffmpeg/libffmpeg_release.so ./android/ffmpeginvoke/src/main/jniLibs/armeabi-v7a/libffmpeg.so

