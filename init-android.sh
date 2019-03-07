#! /bin/sh
#
# init-android.sh
#
# Created by yuqilin on 11/26/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
export FF_BUILD_ROOT=$BASE_DIR/android/build
export FF_OUTPUT_ROOT=$BASE_DIR/android/output

BUILD_ARCHS="armv7a"

FFMPEG_UPSTREAM=https://github.com/Bilibili/FFmpeg.git
FFMPEG_REMOTE=https://github.com/yuqilin/FFmpeg.git
FFMPEG_COMMIT=origin/qmediaplayer
FFMPEG_LOCAL_REPO=extra/ffmpeg

LIBX264_REMOTE=https://github.com/yuqilin/libx264.git
LIBX264_LOCAL_REPO=extra/libx264
LIBX264_COMMIT=stable

LIBMP3LAME_REMOTE=https://github.com/yuqilin/libmp3lame.git
LIBMP3LAME_LOCAL_REPO=extra/libmp3lame
LIBMP3LAME_COMMIT=

LIBFDKAAC_REMOTE=https://github.com/yuqilin/fdk-aac.git
LIBFDKAAC_LOCAL_REPO=extra/fdk-aac
LIBFDKAAC_COMMIT=

mkdir -p $FF_BUILD_ROOT

. ./android/do-detect-env.sh

FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG
FF_GCC_VER=$IJK_GCC_VER
FF_GCC_64_VER=$IJK_GCC_64_VER

FF_ANDROID_PLATFORM=android-9

TOOLS=tools
echo "== pull ffmpeg base =="
sh $TOOLS/pull-repo-base.sh $FFMPEG_REMOTE $FFMPEG_LOCAL_REPO

echo "== pull libx264 base =="
sh $TOOLS/pull-repo-base.sh $LIBX264_REMOTE $LIBX264_LOCAL_REPO

echo "== pull libmp3lame base =="
sh $TOOLS/pull-repo-base.sh $LIBMP3LAME_REMOTE $LIBMP3LAME_LOCAL_REPO

echo "== pull libfdkaac base =="
sh $TOOLS/pull-repo-base.sh $LIBFDKAAC_REMOTE $LIBFDKAAC_LOCAL_REPO

function spushd() {
    pushd "$1" 2>&1> /dev/null
}

function spopd() {
    popd 2>&1> /dev/null
}

function pull_fork() {
    ARCH=$1

    echo "== pull ffmpeg fork $ARCH =="
    FFMPEG_ARCH_SRC=$FF_BUILD_ROOT/$ARCH/ffmpeg
    sh $TOOLS/pull-repo-ref.sh $FFMPEG_LOCAL_REPO $FFMPEG_REMOTE $FFMPEG_ARCH_SRC
    spushd $FFMPEG_ARCH_SRC
    git checkout ${FFMPEG_COMMIT} -B qmediaplayer
    spopd

    echo "== pull libx264 fork $ARCH =="
    LIBX264_ARCH_SRC=$FF_BUILD_ROOT/$ARCH/libx264
    sh $TOOLS/pull-repo-ref.sh $LIBX264_LOCAL_REPO $LIBX264_REMOTE $LIBX264_ARCH_SRC
    spushd $LIBX264_ARCH_SRC
    git checkout ${LIBX264_COMMIT}
    spopd

    # echo "== pull libmp3lame fork $ARCH =="
    # LIBMP3LAME_ARCH_SRC=$FF_BUILD_ROOT/$ARCH/libmp3lame
    # sh $TOOLS/pull-repo-ref.sh $LIBMP3LAME_LOCAL_REPO $LIBMP3LAME_REMOTE $LIBMP3LAME_ARCH_SRC

    echo "== pull fdk-aac fork $ARCH =="
    LIBFDKAAC_ARCH_SRC=$FF_BUILD_ROOT/$ARCH/fdk-aac
    sh $TOOLS/pull-repo-ref.sh $LIBFDKAAC_LOCAL_REPO $LIBFDKAAC_REMOTE $LIBFDKAAC_ARCH_SRC
    # spushd $LIBFDKAAC_ARCH_SRC
    # git checkout ${LIBFDKAAC_COMMIT}
    # spopd
}

FF_TOOLCHAIN_ARCH=arm
for FF_ARCH in $BUILD_ARCHS; do

    ##############################
    # make NDK standalone toolchain
    ##############################

    FF_CROSS_PREFIX=
    if [ "$FF_ARCH" = "armv7a" ]; then
        FF_TOOLCHAIN_ARCH=arm
        FF_CROSS_PREFIX=arm-linux-androideabi
    elif [ "$FF_ARCH" = "arm64" ]; then
        FF_TOOLCHAIN_ARCH=arm64
        FF_CROSS_PREFIX=aarch64-linux-android
        FF_ANDROID_PLATFORM=android-21
    elif [ "$FF_ARCH" = "x86" ]; then
        FF_TOOLCHAIN_ARCH=x86
        FF_CROSS_PREFIX=x86-linux-android
    elif [ "$FF_ARCH" = "x86_64" ]; then
        FF_TOOLCHAIN_ARCH=x86_64
        FF_CROSS_PREFIX=x86_64-linux-android
    fi

    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    FF_TOOLCHAIN_PATH=$FF_BUILD_ROOT/$FF_ARCH/toolchain
    FF_MAKE_TOOLCHAIN_FLAGS="$FF_MAKE_TOOLCHAIN_FLAGS --install-dir=$FF_TOOLCHAIN_PATH"

    FF_TOOLCHAIN_TOUCH="$FF_TOOLCHAIN_PATH/touch"
    if [ ! -f "$FF_TOOLCHAIN_TOUCH" ]; then

        #--------------------
        echo ""
        echo "--------------------"
        echo "[*] make NDK standalone toolchain for $FF_ARCH"
        echo "--------------------"

        $ANDROID_NDK/build/tools/make-standalone-toolchain.sh \
            $FF_MAKE_TOOLCHAIN_FLAGS \
            --platform=$FF_ANDROID_PLATFORM \
            --toolchain=$FF_TOOLCHAIN_NAME

        touch $FF_TOOLCHAIN_TOUCH;
    fi

    pull_fork $FF_ARCH
done
