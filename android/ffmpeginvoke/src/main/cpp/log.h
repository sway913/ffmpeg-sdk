//
// Created by yuqilin on 2018/11/27.
//

#ifndef FFMPEGINVOKEDEMO_LOG_H
#define FFMPEGINVOKEDEMO_LOG_H

#ifndef LOG_TAG
#define LOG_TAG     "ffmpeg-android"
#endif

#ifdef LOG_ENABLE

#include <android/log.h>

#define LOG(...)    __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__);
#define LOGI(...)   __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__);
#define LOGW(...)   __android_log_print(ANDROID_LOG_WARN,  LOG_TAG, __VA_ARGS__);
#define LOGE(...)   __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__);

#define VLOGD(...)  ((void)__android_log_vprint(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define VLOGI(...)  ((void)__android_log_vprint(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__))
#define VLOGE(...)  ((void)__android_log_vprint(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))

#else /* !LOG_ENABLE */

#define LOG(...)
#define LOGI(...)
#define LOGW(...)
#define LOGE(...)

#define VLOGD(...)
#define VLOGI(...)
#define VLOGE(...)

#endif // LOG_ENABLE

#endif // FFMPEGINVOKEDEMO_LOG_H
