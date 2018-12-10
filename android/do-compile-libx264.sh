#! /bin/sh
#
# do-compile-libx264.sh
# 
# Created by yuqilin on 11/29/2018
# Copyright (C) 2018 yuqilin <yuqilin1228@gmail.com>
#

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT=$BASE_DIR/build
OUTPUT_ROOT=$BASE_DIR/output

TARGET_ARCH=$1
BUILD_OPT=$2

BUILD_NAME=libx264

BUILD_ARCH=$BUILD_ROOT/$TARGET_ARCH

NDK_TOOLCHAIN_PATH=$BUILD_ARCH/toolchain

PLATFORM_SYSROOT=$NDK_TOOLCHAIN_PATH/sysroot

X264_ARCH_SRC=$BUILD_ARCH/$BUILD_NAME

X264_MAKE_FLAGS=$IJK_MAKE_FLAG

PREFIX=${OUTPUT_ROOT}/$TARGET_ARCH/$BUILD_NAME

function info() {
    local green='\033[32m'
    local normal='\033[0m'
    echo "[${green}info${normal}] $1"
}

function spushd() {
    pushd "$1" 2>&1> /dev/null
}

function spopd() {
    popd 2>&1> /dev/null
}

if [ "${TARGET_ARCH}" = "armv5" ]; then
    ANDROID_PLATFORM=android-9
    ARCH=arm
    CROSS_PREFIX=arm-linux-androideabi
    TARGET_HOST_CPU=armv6-linux

    # NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
    # info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

    #"-marm -march=armv6 -mfloat-abi=softfp -mfpu=vfp"
    EXTRA_CFLAGS=""
    EXTRA_LDFLAGS=
    EXTRA_CFG_FLAGS=

elif [ "$TARGET_ARCH" = "armv7a" ]; then
    BUILD_NAME=libx264-armv7a
    ANDROID_PLATFORM=android-9
    ARCH=arm
    CROSS_PREFIX=arm-linux-androideabi
    TARGET_HOST_CPU=armv7-linux
    # PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm

    # NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
    # info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

    EXTRA_CFLAGS="-march=armv7-a -fomit-frame-pointer -mfloat-abi=softfp -mfpu=neon"
    EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
    EXTRA_CFG_FLAGS=

elif [ "$TARGET_ARCH" = "arm64" ]; then
    BUILD_NAME=libx264-arm64
    ANDROID_PLATFORM=android-21
    ARCH=aarch64
    CROSS_PREFIX=aarch64-linux-android
    TARGET_HOST_CPU=aarch64-linux
    # PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm64

    # NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_64_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
    # info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

    EXTRA_CFLAGS=""
    EXTRA_LDFLAGS=
    EXTRA_CFG_FLAGS=

else
    echo "!!! Unknown architecture $TARGET_ARCH";
    exit 1
fi


export PATH=$NDK_TOOLCHAIN_PATH/bin/:$PATH
export CC="${CROSS_PREFIX}-gcc"
export CXX="${CROSS_PREFIX}-g++"
export AS="${CROSS_PREFIX}-gcc"
export LD=${CROSS_PREFIX}-ld
export AR=${CROSS_PREFIX}-ar
export RANLIB="${CROSS_PREFIX}-ranlib"
export STRIP=${CROSS_PREFIX}-strip


echo "--------------------"
info "build x264 for arch ${TARGET_ARCH} start"
echo "--------------------"

spushd ${X264_ARCH_SRC}

echo "--------------------"
info "configure x264 for arch $TARGET_ARCH"
echo "--------------------"

./configure \
    --prefix=${PREFIX} \
    --cross-prefix=${CROSS_PREFIX}- \
    --sysroot=${PLATFORM_SYSROOT} \
    --host=${TARGET_HOST_CPU} \
    --extra-cflags="-O2 -g -DANDROID -D__ANDROID__ -DHAVE_PTHREAD -DHAVE_SYS_UIO_H=1 ${EXTRA_CFLAGS} -I${PREFIX}/include" \
    --extra-ldflags="-Wl,-rpath-link=${PLATFORM_SYSROOT}/usr/lib ${EXTRA_LDFLAGS} -L${PLATFORM_SYSROOT}/usr/lib -nostdlib -lc -lm -ldl -llog -lgcc -L${PREFIX}/lib" \
    --enable-static \
    --disable-cli \
    --enable-pic \
    $EXTRA_CFG_FLAGS

echo "--------------------"
info "compile x264 for arch $TARGET_ARCH"
echo "--------------------"

make $X264_MAKE_FLAGS
make install

echo "--------------------"
info "build x264 for arch ${TARGET_ARCH} finish"
echo "--------------------"

spopd
