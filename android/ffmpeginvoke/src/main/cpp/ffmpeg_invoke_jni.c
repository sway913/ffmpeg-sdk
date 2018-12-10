//
// Created by yuqilin on 2018/11/28.
//

#define LOG_TAG "ffmpeg_invoke"

#include <jni.h>
#include <dlfcn.h>
#include "log.h"

#define FFMPEG_INVOKE_CLASS     "com/github/yql/ffmpeginvoke/FFmpegInvoke"

static JavaVM *g_jvm = NULL;

typedef void (*fun_ffmpeg_run_t)(JNIEnv*, jobject, jobjectArray);

// Use to safely invoke ffmpeg multiple times from the same Activity
JNIEXPORT void JNICALL ffmpeg_invoke_run(JNIEnv *env, jobject obj, jstring libffmpeg_path, jobjectArray ffmpeg_args) {
    const char* path;
    void* handle;

    path = (*env)->GetStringUTFChars(env, libffmpeg_path, 0);
    handle = dlopen(path, RTLD_LAZY);
    if (handle == NULL) {
        LOG("error:dlopen ffmpeg failed : %s", path);
        goto fail;
    }

    fun_ffmpeg_run_t fun_ffmpeg_run = dlsym(handle, "ffmpeg_run");
    if (fun_ffmpeg_run != NULL) {
        (*fun_ffmpeg_run)(env, obj, ffmpeg_args);
    } else {
        LOG("error:dlsym ffmpeg_run is NULL !!!");
    }

    dlclose(handle);

fail:
    (*env)->ReleaseStringUTFChars(env, libffmpeg_path, path);
}

static JNINativeMethod g_nativeMethods[] = {
        {
                "run",
                "(Ljava/lang/String;[Ljava/lang/String;)V",
                (void *) ffmpeg_invoke_run
        },
};

extern JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {

    g_jvm = vm;

    LOG("JNI_OnLoad, g_jvm=%p", g_jvm);

    JNIEnv *env = NULL;
    jint status = (*g_jvm)->GetEnv(g_jvm, (void **)&env, JNI_VERSION_1_4);

    jclass cls = (*env)->FindClass(env, FFMPEG_INVOKE_CLASS);
    if (!cls) {
        LOG("error:findclass failed for class'%s'", FFMPEG_INVOKE_CLASS);
    }

    if ((*env)->RegisterNatives(env, cls, g_nativeMethods, sizeof(g_nativeMethods) / sizeof(g_nativeMethods[0])) < 0) {
        LOG("error:register natives failed for class'%s'", FFMPEG_INVOKE_CLASS);
        return -1;
    }

    return JNI_VERSION_1_4;
}

extern JNIEXPORT void JNICALL JNI_OnUnload(JavaVM* vm, void* reserved) {
    LOG("JNI_OnUnload");
}


