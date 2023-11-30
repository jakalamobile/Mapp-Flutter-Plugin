package com.mapp.flutter.sdk;

import com.appoxee.DeviceInfo;
import com.appoxee.internal.inapp.model.APXInboxMessage;
import com.appoxee.internal.inapp.model.ApxInAppExtras;
import com.appoxee.push.PushData;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class MappSerializer {
    public static Map<String, Object> deviceInfoToMap(DeviceInfo deviceInfo) {
        Map<String, Object> map = new HashMap<>();
        try {
            map.put("id", deviceInfo.id);
            map.put("appVersion", deviceInfo.appVersion);
            map.put("sdkVersion", deviceInfo.sdkVersion);
            map.put("locale", deviceInfo.locale);
            map.put("timezone", deviceInfo.timezone);
            map.put("deviceModel", deviceInfo.deviceModel);
            map.put("manufacturer", deviceInfo.manufacturer);
            map.put("osVersion", deviceInfo.osVersion);
            map.put("resolution", deviceInfo.resolution);
            map.put("density", String.valueOf(deviceInfo.density));
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    public static Map<String, Object> pushDataToMap(PushData data, String type) {
        Map<String, Object> map = new HashMap<>();

        try {
            map.put("id", data.id);
            map.put("title", data.title);
            map.put("bigText", data.bigText);
            map.put("sound", data.sound);
            map.put("pushNotificationEventType", type);
            if (data.actionUri != null)
                map.put("actionUri", data.actionUri.toString());
            map.put("collapseKey", data.collapseKey);
            map.put("badgeNumber", data.badgeNumber);
            map.put("silentType", data.silentType);
            map.put("silentData", data.silentData);
            map.put("category", data.category);
            map.put("android_apx_media", data.iosApxMedia);
            if (data.extraFields != null)
                for (Map.Entry<String, String> entry : data.extraFields.entrySet()) {
                    String key = entry.getKey();
                    String value = entry.getValue();
                    map.put(key, value);
                }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    public static JSONObject messageToJson(APXInboxMessage msg) {
        JSONObject msgJson=new JSONObject();

        try {
            msgJson.put("templateId", msg.getTemplateId());
            msgJson.put("title", msg.getContent());
            msgJson.put("eventId", msg.getEventId());
            if (msg.getExpirationDate() != null)
                msgJson.put("expirationDate", msg.getExpirationDate().toString());
            if (msg.getIconUrl() != null)
                msgJson.put("iconURl", msg.getIconUrl());
            if (msg.getStatus() != null)
                msgJson.put("status", msg.getStatus());
            if (msg.getSubject() != null)
                msgJson.put("subject", msg.getSubject());
            if (msg.getSummary() != null)
                msgJson.put("summary", msg.getSummary());
            if (msg.getExtras() != null)
                for (ApxInAppExtras apxInAppExtras : msg.getExtras())
                    msgJson.put(apxInAppExtras.getName(), apxInAppExtras.getValue());


        } catch (Exception e) {
            e.printStackTrace();
        }

        return msgJson;
    }
}
