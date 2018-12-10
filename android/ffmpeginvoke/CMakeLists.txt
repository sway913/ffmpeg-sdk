# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_VERBOSE_MAKEFILE ON)
MESSAGE("ANDROID_ARM_MODE is ${ANDROID_ARM_MODE}")

#set(FFMPEG_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../extra/ffmpeg)

if( ${ANDROID_ABI} STREQUAL "armeabi")
    set(FFMPEG_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../build/armv5/ffmpeg)
    set(FFMPEG_INC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv5/ffmpeg/include ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv5/ffmpeg/include/libffmpeg)
    set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv5/ffmpeg)
elseif( ${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(FFMPEG_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../build/armv7a/ffmpeg)
    set(FFMPEG_INC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv7a/ffmpeg/include ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv7a/ffmpeg/include/libffmpeg)
    set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/armv7a/ffmpeg)
elseif(${ANDROID_ABI} STREQUAL "arm64-v8a")
    set(FFMPEG_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../build/arm64/ffmpeg)
    set(FFMPEG_INC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/arm64/ffmpeg/include ${CMAKE_CURRENT_SOURCE_DIR}/../output/arm64/ffmpeg/include/libffmpeg)
    set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../output/arm64/ffmpeg)
endif()

set(FFMPEG_INC_DIR ${FFMPEG_INC_DIR} ${FFMPEG_SRC_DIR})

MESSAGE("ANDROID_ABI is ${ANDROID_ABI}")
MESSAGE("FFMPEG_INC_DIR is ${FFMPEG_INC_DIR}")
MESSAGE("FFMPEG_SRC_DIR is ${FFMPEG_SRC_DIR}")

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds it for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             ffmpeg_android

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             src/main/cpp/ffmpeg_android_jni.c
             src/main/cpp/cmdutils.c
             src/main/cpp/ffmpeg_main.c
             src/main/cpp/ffmpeg_filter.c
             src/main/cpp/ffmpeg_opt.c
            )

add_library(
            ffmpeg_invoke

            SHARED

            src/main/cpp/ffmpeg_invoke_jni.c)

add_library( # Sets the name of the library.
             ffmpeg-lib
             SHARED
             IMPORTED
            )

set_target_properties( # Specifies the target library.

            ffmpeg-lib

            # Specifies the parameter you want to define.
            PROPERTIES IMPORTED_LOCATION

            # Provides the path to the library you want to import.
            ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libffmpeg.so )


include_directories( ${FFMPEG_INC_DIR} )

## Searches for a specified prebuilt library and stores the path as a
## variable. Because system libraries are included in the search path by
## default, you only need to specify the name of the public NDK library
## you want to add. CMake verifies that the library exists before
## completing its build.

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

## Specifies libraries CMake should link to your target library. You
## can link multiple libraries, such as libraries you define in the
## build script, prebuilt third-party libraries, or system libraries.

target_link_libraries(
                # Specifies the target library.
                ffmpeg_android

                ffmpeg-lib

                # Links the target library to the log library
                # included in the NDK.
                ${log-lib} )

target_link_libraries(
                        ffmpeg_invoke
                        ${log-lib} )
