package com.github.yql.ffmpeginvoke;

public class FFmpegInvoke {
    static {
        System.loadLibrary("ffmpeg_invoke");
    }

    public static void help(String ffmpegPath) {
        FFmpegInvoke ffmpeg = new FFmpegInvoke();
        ffmpeg.run(ffmpegPath, new String[]{
                "ffmpeg", "-h"
        });
    }

    public native void run(String ffmpegPath, String[] args);
}
