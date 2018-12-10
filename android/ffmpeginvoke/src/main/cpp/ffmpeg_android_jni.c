//
// Created by yuqilin on 2018/11/27.
//

#include <jni.h>
#include "log.h"
#include "libavutil/log.h"

#define FFMPEG_ANDROID_CLASS     "com/github/yql/ffmpeginvoke/FFmpegAndroid"

extern int main(int argc, char **argv);

static JavaVM *g_jvm = NULL;

//static jclass g_ffmpeg_cls = NULL;

static jobject g_ffmpeg_obj = NULL;

static jmethodID g_post_event = NULL;

typedef void (*ff_progress_cb_t)(int time_ms, int progress);

static ff_progress_cb_t ff_progress_cb = NULL;

#define MSG_TRANSCODE_PROGRESS 1

static void ff_progress_callback_jni(int time_ms, int progress) {
    JNIEnv *env = NULL;
    jboolean need_detach = JNI_FALSE;
    // 获取当前native线程是否有没有被附加到jvm环境中
    int getEnvStat = (*g_jvm)->GetEnv(g_jvm, (void **)&env, JNI_VERSION_1_4);
    if (getEnvStat == JNI_EDETACHED) {
        //如果没有， 主动附加到jvm环境中，获取到env
        if ((*g_jvm)->AttachCurrentThread(g_jvm, &env, NULL) != 0) {
            return;
        }
        need_detach = JNI_TRUE;
    }

//    if (g_ffmpeg_cls != NULL && g_post_event == NULL) {
//        g_post_event = (*env)->GetStaticMethodID(env, g_ffmpeg_cls, "postEventFromNative", "(Ljava/lang/Object;III)V");
//    }
//
//    if (g_ffmpeg_cls && g_post_event) {
//        (*env)->CallStaticVoidMethod(env, g_ffmpeg_cls, g_post_event,
//                                  0, MSG_TRANSCODE_PROGRESS, time_ms, progress);
//    }

    if (g_ffmpeg_obj != NULL) {
        jclass ff_cls = (*env)->GetObjectClass(env, g_ffmpeg_obj);
        jmethodID func_onProgress_id = (*env)->GetMethodID(env, ff_cls, "onProgress", "(II)V");
        if (func_onProgress_id != NULL) {
            (*env)->CallVoidMethod(env, g_ffmpeg_obj, func_onProgress_id, time_ms, progress);
        }
        (*env)->DeleteLocalRef(env, ff_cls);
    }

    //释放当前线程
    if(need_detach) {
        (*g_jvm)->DetachCurrentThread(g_jvm);
    }
    env = NULL;
}

/**
 * 从日志信息中获取转码进度
 */
void parse_transcode_progress(const char *log) {
    char time_str[8] = "time=";
    char progress_str[16] = "progress=";
    char *pt = strstr(log, time_str);
    char *pp = strstr(log, progress_str);

    if(pt != NULL && pp != NULL) {
        char str[17] = {0};
        strncpy(str, pt, 16);
        int h =(str[5]-'0')*10+(str[6]-'0');
        int m =(str[8]-'0')*10+(str[9]-'0');
        int s =(str[11]-'0')*10+(str[12]-'0');
        int ss =(str[14]-'0')*10+(str[15]-'0');

        char num[4] = {0, 0, 0, 0};
        strncpy(num, pp + 9, 3);

        int time_ms = (s + m*60 + h*60*60) * 1000 + ss * 10;
        int progress = atoi(num);

//        if (ff_progress_cb) {
//            ff_progress_cb(time_ms, progress);
//        }
        ff_progress_callback_jni(time_ms, progress);
    }
}

/**
 * 日志信息处理回调
 * @param ptr
 * @param level
 * @param fmt
 * @param vl
 */
static void log_callback_process(void *ptr, int level, const char *fmt, va_list vl) {
    static int print_prefix = 1;
    static char prev[1024];
    char line[1024];
    av_log_format_line(ptr, level, fmt, vl, line, sizeof(line), &print_prefix);
    strcpy(prev, line);

    parse_transcode_progress(line);
}

static void ffp_log_callback_brief(void *ptr, int level, const char *fmt, va_list vl) {
    VLOGD(fmt, vl);

    log_callback_process(ptr, level, fmt, vl);
}

JNIEXPORT int JNICALL ffmpeg_create(JNIEnv *env, jobject obj) {
    if(g_ffmpeg_obj == NULL) {
        g_ffmpeg_obj = (*env)->NewGlobalRef(env, obj);
    }
    return 0;
}

JNIEXPORT int JNICALL ffmpeg_destroy(JNIEnv *env, jobject obj) {
    if(g_ffmpeg_obj != NULL) {
        (*env)->DeleteGlobalRef(env, obj);
        g_ffmpeg_obj = NULL;
    }
}

JNIEXPORT void JNICALL ffmpeg_run(JNIEnv *env, jobject obj, jobjectArray args) {
    int i = 0;
    int argc = 0;
    char **argv = NULL;
    char **strObjs = NULL;

    if (args != NULL) {
        argc = (*env)->GetArrayLength(env, args);
        argv = (char **) malloc(sizeof(char *) * argc);
        strObjs = (jstring *)malloc(sizeof(jstring) * argc);

        for(i = 0; i < argc; i++) {
            strObjs[i] = (jstring)(*env)->GetObjectArrayElement(env, args, i);
            argv[i] = (char *)(*env)->GetStringUTFChars(env, strObjs[i], NULL);
        }
    }

    av_log_set_level(AV_LOG_DEBUG);
    av_log_set_callback(ffp_log_callback_brief);

    main(argc, argv);

    for(i = 0; i < argc; i++) {
        (*env)->ReleaseStringUTFChars(env, strObjs[i], argv[i]);
    }

    LOG("ffmpeg_run, 0");
    free(strObjs);
    LOG("ffmpeg_run, 1");
    free(argv);
    LOG("ffmpeg_run, 2");
}

static JNINativeMethod g_nativeMethods[] = {
        {
            "create",
            "()I",
            (void *)ffmpeg_create
        },
        {
            "destroy",
            "()V",
            (void *)ffmpeg_destroy
        },
        {
            "run",
            "([Ljava/lang/String;)V",
            (void *) ffmpeg_run
        },
};

extern JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {

    g_jvm = vm;

    LOG("JNI_OnLoad, g_jvm=%p", g_jvm);

    JNIEnv *env = NULL;
    jint status = (*g_jvm)->GetEnv(g_jvm, (void **)&env, JNI_VERSION_1_4);

    jclass cls = (*env)->FindClass(env, FFMPEG_ANDROID_CLASS);
    if (!cls) {
        LOG("error:findclass failed for class'%s'", FFMPEG_ANDROID_CLASS);
    }

//    if (!g_ffmpeg_cls) {
//        g_ffmpeg_cls = (jclass) (*env)->NewGlobalRef(env, cls);
//    }

    if ((*env)->RegisterNatives(env, cls, g_nativeMethods, sizeof(g_nativeMethods) / sizeof(g_nativeMethods[0])) < 0) {
        LOG("error:register natives failed for class'%s'", FFMPEG_ANDROID_CLASS);
        return -1;
    }

    (*env)->DeleteLocalRef(env, cls);

    return JNI_VERSION_1_4;
}

extern JNIEXPORT void JNICALL JNI_OnUnload(JavaVM* vm, void* reserved) {
    LOG("JNI_OnUnload");

//    JNIEnv *env = NULL;
//    jint status = (*g_jvm)->GetEnv(g_jvm, (void **)&env, JNI_VERSION_1_4);

//    if (g_ffmpeg_cls) {
//        (*env)->DeleteGlobalRef(env, g_ffmpeg_cls);
//        g_ffmpeg_cls = NULL;
//    }
}

