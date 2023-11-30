package com.mapp.flutter.sdk;

import android.content.Context;
import android.content.Intent;
import android.os.Looper;

import com.appoxee.internal.logger.Logger;
import com.appoxee.internal.logger.LoggerFactory;
import com.appoxee.push.PushData;
import com.appoxee.push.PushDataReceiver;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

public class PushBroadcastReceiver extends PushDataReceiver {
    private final Logger devLogger = LoggerFactory.getDevLogger();

    private MethodChannel backgroundMethodChannel;

    static PushData lastMessageRecived;

    @Override
    public void onBroadcastReceived(Context context, Intent intent) {
        super.onBroadcastReceived(context, intent);
        devLogger.d(intent);
        if (EventEmitter.getInstance().getChannel() == null) {
            FlutterEngine flutterEngine = new FlutterEngine(context, null);
            DartExecutor executor = flutterEngine.getDartExecutor();
            backgroundMethodChannel = new MethodChannel(executor.getBinaryMessenger(), MappSdkPlugin.MAPP_CHANNEL_NAME);

            //exception is thrown on flutter side when methodCallHandler not set, even empty one!
            backgroundMethodChannel.setMethodCallHandler(((call, result) -> {
            }));
            executor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());

            // initialize plugin
            flutterEngine.getBroadcastReceiverControlSurface().attachToBroadcastReceiver(this, null);

            EventEmitter.getInstance().attachChannel(backgroundMethodChannel);
        }
    }

    @Override
    public void onPushReceived(PushData pushData) {
        super.onPushReceived(pushData);
        devLogger.d(pushData);
        EventEmitter.getInstance()
                .sendEvent(new PushNotificationEvent(pushData, "handledRemoteNotification"));
    }

    @Override
    public void onPushOpened(PushData pushData) {
        super.onPushOpened(pushData);
        devLogger.d(pushData);
        lastMessageRecived = pushData;
        EventEmitter.getInstance()
              .sendEvent(new PushNotificationEvent(pushData, "handledPushOpen"));
    }

    @Override
    public void onPushDismissed(PushData pushData) {
        super.onPushDismissed(pushData);
        EventEmitter.getInstance()
                .sendEvent(new PushNotificationEvent(pushData, "handledPushDismiss"));
    }

    @Override
    public void onSilentPush(PushData pushData) {
        super.onSilentPush(pushData);
        EventEmitter.getInstance()
                .sendEvent(new PushNotificationEvent(pushData, "handledPushSilent"));
    }

}
