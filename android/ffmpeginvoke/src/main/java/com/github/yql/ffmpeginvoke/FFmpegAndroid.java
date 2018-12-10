package com.github.yql.ffmpeginvoke;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

public class FFmpegAndroid {

    private static final String TAG = "FFmpegAndroid";

    public static final int MSG_TRANSCODE_PROGRESS = 1;

    static {
        System.loadLibrary("ffmpeg_android");
    }

    public static void help() {
        FFmpegAndroid ffmpeg = new FFmpegAndroid(null);
        ffmpeg.run(new String[]{
                "ffmpeg", "-h"
        });
    }

    public interface FFListener {
        void onProgress(int ms, int progress);
    }

    private FFListener ffListener;

    public FFmpegAndroid(FFListener listener) {
        ffListener = listener;
        createEventHandler();
    }

    public void onProgress(int ms, int progress) {
        Log.d(TAG, "onProgress ms=" + ms + ", progress=" + progress);
        if (ffListener != null) {
            ffListener.onProgress(ms, progress);
        }
    }

    public native int create();

    public native void destroy();

    public native void run(String[] args);

    private class EventHandler extends Handler {
        FFmpegAndroid ffmpeg = null;

        public EventHandler(Looper looper, FFmpegAndroid ffmpeg) {
            super(looper);
            this.ffmpeg = ffmpeg;
        }

        @Override
        public void handleMessage(Message msg) {

            if (ffmpeg.nativeContext == 0) {
                Log.d(TAG, "handleMessage, mediaplayer went away with unhandled events");
                return;
            }

            switch (msg.what) {
                case MSG_TRANSCODE_PROGRESS:
                    if (ffListener != null) {
                        ffListener.onProgress(msg.arg1, msg.arg2);
                    }
                    break;
            }
        }
    }

    private long nativeContext = 0;

    private EventHandler eventHandler = null;
    private void createEventHandler() {
        Looper looper;
        if ((looper = Looper.myLooper()) != null) {
            Log.d(TAG, "createEventHandler, Use current Thread Looper...");
            eventHandler = new EventHandler(looper, this);
        } else if ((looper = Looper.getMainLooper()) != null) {
            Log.d(TAG, "createEventHandler, Use Main Thread Looper...");
            eventHandler = new EventHandler(looper, this);
        } else {
            Log.d(TAG, "createEventHandler, create mEventHandler from null");
            eventHandler = null;
        }
    }

    private static void postEventFromNative(Object object, int what, int arg1, int arg2) {

        Log.d(TAG, "postEventFromNative, what = " + what + ",arg1 = " + arg1 + ",arg2 = " + arg2);

        FFmpegAndroid ffmpeg = (FFmpegAndroid)object;
        if (ffmpeg == null) {
            return;
        }

        if (ffmpeg.eventHandler != null) {
            Message message = ffmpeg.eventHandler.obtainMessage(what, arg1, arg2);
            ffmpeg.eventHandler.sendMessage(message);
        }
    }

}
