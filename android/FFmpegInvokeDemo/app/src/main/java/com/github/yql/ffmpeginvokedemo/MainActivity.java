package com.github.yql.ffmpeginvokedemo;

import android.Manifest;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.daimajia.numberprogressbar.NumberProgressBar;
import com.github.yql.ffmpeginvoke.FFmpegAndroid;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    public static final int REQUEST_CODE = 1001;

    private Button startBtn;
    private NumberProgressBar progressBar;
    private TextView progressTime;

    private FFmpegAndroid ffmpeg;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        progressBar = findViewById(R.id.progress_bar);
        progressTime = findViewById(R.id.progress_time);

        progressBar.setMax(100);

        startBtn = findViewById(R.id.start_btn);
        startBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                progressBar.setProgress(0);
                progressTime.setText("00:00:00.000");
                runFFmpegCmd();
            }
        });

        PermissionUtil.checkPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE, REQUEST_CODE,
                "Storage Access need to be granted!", "Storage Access NOT granted",
                new PermissionUtil.ReqPermissionCallback() {
                    @Override
                    public void onResult(boolean success) {

                    }
                });


//        FFmpegAndroid.help();

        ffmpeg = new FFmpegAndroid(new FFmpegAndroid.FFListener() {
            @Override
            public void onProgress(int ms, final int progress) {
                final String time = millisToString(ms, false);
                Log.d(TAG, "onProgress time : " + time + ", progress : " + progress);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        progressBar.setProgress(progress);
                        progressTime.setText(time);
                    }
                });
            }
        });
        ffmpeg.create();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (ffmpeg != null)
            ffmpeg.destroy();
    }

    private void runFFmpegCmd() {
        String ffmpegPath = getApplicationInfo().nativeLibraryDir + "/libffmpeg_android.so";
//        Log.d(TAG, "ffmpegPath : " + ffmpegPath);
//        FFmpegInvoke.help(ffmpegPath);

        final String command = "ffmpeg -ss 0 -i /sdcard/test.mp4 -vframes 1 -y /sdcard/test.jpg";
//        final String command = "ffmpeg -ss 0 -i /sdcard/test.mp4 -t 30 -vcodec copy -acodec copy -y /sdcard/test2.mp4";
//        final String command = "ffmpeg -y -i /sdcard/test.mp4 -movflags faststart -b:v 200k  -vcodec libx264 -acodec libfdk_aac /sdcard/test3.mp4";
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                if (ffmpeg != null)
                    ffmpeg.run(command.split("\\s+"));
            }
        });
        thread.setPriority(Thread.NORM_PRIORITY - 1);
        thread.start();
//        new FFmpegInvoke().run(ffmpegPath, command.split(" "));
    }


    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        PermissionUtil.onRequestPermissionResult(this, requestCode, permissions, grantResults);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        PermissionUtil.onActivityResult(this, requestCode);
    }

    private static StringBuilder sb = new StringBuilder();
    private static DecimalFormat format = (DecimalFormat) NumberFormat.getInstance(Locale.US);
    private static DecimalFormat msFormat = (DecimalFormat) NumberFormat.getInstance(Locale.US);

    static {
        format.applyPattern("00");
        msFormat.applyPattern("000");
    }

    public static String millisToString(long millis, boolean text) {
        sb.setLength(0);
        if (millis < 0) {
            millis = -millis;
            sb.append("-");
        }

        if (millis == 0) {
            return text ? "0s" : "0:00";
        } else if (millis < 1000) {
            return text ? "1s" : "0:01";
        }

        int ms = (int) millis % 1000;
        millis /= 1000;
        int sec = (int) (millis % 60);
        millis /= 60;
        int min = (int) (millis % 60);
        millis /= 60;
        int hours = (int) millis;

        if (text) {
            if (millis > 0)
                sb.append(hours).append('h').append(format.format(min)).append("min");
            else if (min > 0)
                sb.append(min).append("min");
            else
                sb.append(sec).append("s");
        } else {
            if (millis > 0)
                sb.append(format.format(hours)).append(':').append(format.format(min)).append(':').append(format.format(sec));
            else
                sb.append(format.format(min)).append(':').append(format.format(sec));
            if (ms > 0) {
                sb.append('.').append(msFormat.format(ms));
            }
        }
        return sb.toString();
    }

}
