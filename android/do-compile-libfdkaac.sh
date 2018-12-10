#! /bin/sh
#
# do-compile-libfdkaac.sh
# 
# Created by yuqilin on 11/30/2018
# Copyright (C) 2018 yuqilin <yuqilin1228@gmail.com>
#


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT=$BASE_DIR/build
OUTPUT_ROOT=$BASE_DIR/output

TARGET_ARCH=$1
BUILD_OPT=$2

BUILD_NAME=fdk-aac

BUILD_ARCH=$BUILD_ROOT/$TARGET_ARCH

NDK_TOOLCHAIN_PATH=$BUILD_ARCH/toolchain

PLATFORM_SYSROOT=$NDK_TOOLCHAIN_PATH/sysroot

FDKAAC_ARCH_SRC=$BUILD_ARCH/$BUILD_NAME

echo FDKAAC_ARCH_SRC=$FDKAAC_ARCH_SRC

FDKAAC_MAKE_FLAGS=$IJK_MAKE_FLAG

echo FDKAAC_MAKE_FLAGS=$FDKAAC_MAKE_FLAGS

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
    TARGET_HOST=arm-linux-androideabi
    TARGET_HOST_CPU=armv6-linux

    # NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
    # info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

    #"-marm -march=armv6 -mfloat-abi=softfp -mfpu=vfp"
    EXTRA_CFLAGS=""
    EXTRA_LDFLAGS=
    EXTRA_CFG_FLAGS=

elif [ "$TARGET_ARCH" = "armv7a" ]; then
    ANDROID_PLATFORM=android-9
    ARCH=arm
    TARGET_HOST=arm-linux-androideabi
    TARGET_HOST_CPU=armv7-linux
    # PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm

    # NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
    # info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

    EXTRA_CFLAGS="-march=armv7-a -fomit-frame-pointer -mfloat-abi=softfp -mfpu=neon"
    EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
    EXTRA_CFG_FLAGS=

elif [ "$TARGET_ARCH" = "arm64" ]; then
    ANDROID_PLATFORM=android-21
    ARCH=aarch64
    TARGET_HOST=aarch64-linux-android
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
export CC="${TARGET_HOST}-gcc"
export CXX="${TARGET_HOST}-g++"
export AS="${TARGET_HOST}-gcc"
export LD=${TARGET_HOST}-ld
export AR=${TARGET_HOST}-ar
export RANLIB="${TARGET_HOST}-ranlib"
export STRIP=${TARGET_HOST}-strip


echo "--------------------"
info "build fdk-aac for arch ${TARGET_ARCH} start"
echo "--------------------"

cd ${FDKAAC_ARCH_SRC}

echo "--------------------"
info "configure fdk-aac for arch $TARGET_ARCH"
echo "--------------------"

./autogen.sh
 #LDFLAGS="-Wl,-rpath-link=${PLATFORM_SYSROOT}/usr/lib -L${PLATFORM_SYSROOT}/usr/lib -nostdlib -lc -lm -ldl -llog -L${PREFIX}/lib" \
./configure \
    CFLAGS="-O2 -fpic -g -DANDROID -DHAVE_SYS_UIO_H=1 ${EXTRA_CFLAGS} -I${PREFIX}/include" \
    --prefix=${PREFIX} \
    --host=${TARGET_HOST} \
    --enable-static \
    --disable-shared \
    --with-pic \
    --with-sysroot=${PLATFORM_SYSROOT}

echo "--------------------"
info "compile fdk-aac for arch $TARGET_ARCH"
echo "--------------------"

make clean
make $FDKAAC_MAKE_FLAGS
make install

echo "--------------------"
info "build fdk-aac for arch ${TARGET_ARCH} finish"
echo "--------------------"

# spopd
