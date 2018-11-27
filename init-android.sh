#! /bin/sh
#
# init-android.sh
# 
# Created by yuqilin on 11/26/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
export FF_BUILD_ROOT=$SCRIPT_DIR/android/build
export FF_OUTPUT_ROOT=$SCRIPT_DIR/android/output

FFMPEG_UPSTREAM=https://github.com/Bilibili/FFmpeg.git
FFMPEG_REMOTE=https://github.com/yuqilin/FFmpeg.git
FFMPEG_COMMIT=ff3.4--ijk0.8.7--20180103--001
FFMPEG_LOCAL_REPO=extra/ffmpeg

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

function pull_fork()
{
    ARCH=$1
    echo "== pull ffmpeg fork $ARCH =="
    FFMPEG_ARCH_SRC=$FF_BUILD_ROOT/$ARCH/ffmpeg
    sh $TOOLS/pull-repo-ref.sh ${FFMPEG_LOCAL_REPO} $FFMPEG_REMOTE $FFMPEG_ARCH_SRC
    # sh $TOOLS/pull-repo-ref.sh $LIBX264_REMOTE android/contrib/libx264-$1 ${LIBX264_LOCAL}
    cd $FFMPEG_ARCH_SRC
    git checkout ${FFMPEG_COMMIT} -B qmediaplayer
    cd -
    # cd android/contrib/libx264-$1
    # git checkout ${LIBX264_COMMIT}
    # cd -
}

for FF_ARCH in $BUILD_ARCHS; do
    
    ##############################
    # make NDK standalone toolchain
    ##############################

    FF_CROSS_PREFIX=
    if [ "$FF_ARCH" = "armv7a" ]; then
        FF_CROSS_PREFIX=arm-linux-androideabi
    elif [ "$FF_ARCH" = "arm64" ]; then
        FF_CROSS_PREFIX=aarch64-linux-androideabi
        FF_ANDROID_PLATFORM=android-21
    elif [ "$FF_ARCH" = "x86" ]; then
        FF_CROSS_PREFIX=x86-linux-android
    elif [ "$FF_ARCH" = "x86_64" ]; then
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

##############################
# init config
##############################
./init-config.sh
