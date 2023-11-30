package com.mapp.flutter.sdk;

public interface Method {
    String GET_PLATFORM_VERSION = "getPlatformVersion";
    String ENGAGE = "engage";
    String SET_DEVICE_ALIAS = "setDeviceAlias";
    String GET_DEVICE_ALIAS = "getDeviceAlias";
    String IS_PUSH_ENABLED = "isPushEnabled";
    String OPT_IN = "optIn";
    String TRIGGER_IN_APP = "triggerInApp";
    String IS_READY = "isReady";
    String GET_DEVICE_INFO = "getDeviceInfo";
    String FETCH_INBOX_MESSAGE = "fetchInboxMessage";
    String FETCH_INBOX_MESSAGES = "fetchInboxMessages";
    String GET_FCM_TOKEN = "getFcmToken";
    String SET_TOKEN = "setToken";
    String START_GEOFENCING = "startGeofencing";
    String STOP_GEOFENCING = "stopGeofencing";
    String ADD_TAG = "addTag";
    String FETCH_DEVICE_TAGS = "fetchDeviceTags";
    String LOGOUT_WITH_OPT_IN = "logoutWithOptin";
    String IS_DEVICE_REGISTERED = "isDeviceRegistered";
    String SET_REMOTE_MESSAGE = "setRemoteMessage";
    String REMOVE_BADGE_NUMBER = "removeBadgeNumber";
    String INAPP_MARK_AS_READ = "inAppMarkAsRead";
    String INAPP_MARK_AS_UNREAD = "inAppMarkAsUnread";
    String INAPP_MARK_AS_DELETED = "inAppMarkAsDeleted";

    String GET_INITIAL_MESSAGE = "getInitialMessage";

    String PERSMISSION_REQUEST_POST_NOTIFICATION="requestPermissionPostNotification";
}
