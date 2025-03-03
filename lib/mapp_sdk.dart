import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'helper_classes.dart';
import 'method.dart';

class MappSdk {
  // static const MethodChannel _channel = MethodChannel('mapp_sdk');
  // MappSdk.setMethodCallHandler(_platformCallHandler);

  static const MethodChannel _privateChannel = MethodChannel('mapp_sdk');

  static MethodChannel get _channel {
    _privateChannel.setMethodCallHandler(_platformCallHandler);
    return _privateChannel;
  }

  //inapp handlers
  static late void Function(dynamic) didReceiveDeepLinkWithIdentifier;
  static late void Function(dynamic) didReceiveInappMessageWithIdentifier;
  static late void Function(dynamic) didReceiveCustomLinkWithIdentifier;
  static late void Function(dynamic) didReceiveInBoxMessages;
  static late void Function(dynamic) inAppCallFailedWithResponse;
  static late void Function(dynamic) didReceiveInBoxMessage;

  //push notification handlers
  static late void Function(dynamic) handledRemoteNotification;
  static late void Function(dynamic) handledRichContent;

  //android push message handlers
  static late void Function(dynamic) handledPushOpen;
  static late void Function(dynamic) handledPushDismiss;
  static late void Function(dynamic) handledPushSilent;

  static Future<void> _platformCallHandler(MethodCall call) {
    try {
      debugPrint(call.method);

      switch (call.method) {
        case Method.DID_RECEIVE_DEEP_LINK_WITH_IDENTIFIER:
          didReceiveDeepLinkWithIdentifier(call.arguments);
          break;
        case Method.DID_RECEIVE_INAPP_MESSAGE_WITH_IDENTIFIER:
          didReceiveInappMessageWithIdentifier(call.arguments);
          break;
        case Method.DID_RECEIVE_CUSTOM_LINK_WITH_IDENTIFIER:
          didReceiveCustomLinkWithIdentifier(call.arguments);
          break;
        case Method.DID_RECEIVE_INBOX_MESSAGES:
          didReceiveInBoxMessages(call.arguments);
          break;
        case Method.INAPP_CALL_FAILED_WITH_RESPONSE:
          inAppCallFailedWithResponse(call.arguments);
          break;
        case Method.DID_RECEIVE_INBOX_MESSAGE:
          didReceiveInBoxMessage(call.arguments);
          break;
        case Method.HANDLED_REMOTE_NOTIFICATION:
          handledRemoteNotification(call.arguments);
          break;
        case Method.HANDLED_RICH_CONTENT:
          handledRichContent(call.arguments);
          break;
        case Method.HANDLED_PUSH_OPEN:
          handledPushOpen(call.arguments);
          break;
        case Method.HANDLED_PUSH_DISMISS:
          handledPushDismiss(call.arguments);
          break;
        case Method.HANDLED_PUSH_SILENT:
          handledPushSilent(call.arguments);
          break;
        default:
          debugPrint('Unknowm method ${call.method} ');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return Future.value();
  }

  static Future<String> get platformVersion async {
    String? version = await _channel.invokeMethod(Method.GET_PLATFORM_VERSION);
    return version ?? "unknown";
  }

  static Future<String?> engage(String sdkKey, String googleProjectId,
      SERVER server, String appID, String tenantID) async {
    final String? version = await _channel.invokeMethod(
        Method.ENGAGE, [sdkKey, "", server.index, appID, tenantID]);
    return 'successfull $version engage method invoked';
  }

  static Future<String?> postponeNotificationRequest(bool postpone) async {
    final String? version = await _channel
        .invokeMethod(Method.POSTPONE_NOTIFICATION_REQUEST, [postpone]);
    return 'successfull $version postponeNotificationRequest method invoked';
  }

  static Future<String?> showNotificationsOnForeground(
      bool showNotification) async {
    if (Platform.isIOS) {
      final String? version = await _channel.invokeMethod(
          Method.SHOW_NOTIFICATION_ON_FOREGROUND, [showNotification]);
      return 'successfull $version postponeNotificationRequest method invoked';
    } else {
      return 'Required only for iOS.';
    }
  }

  static Future<bool> isReady() async {
    final bool ready = await _channel.invokeMethod(Method.IS_READY);
    return ready;
  }

  static Future<String?> setPushEnabled(bool optIn) async {
    final bool isPushEnabled =
        await _channel.invokeMethod(Method.OPT_IN, [optIn]);
    return 'OptIn set to: $isPushEnabled opted in device with value $optIn';
  }

  static Future<bool> isPushEnabled() async {
    final bool version = await _channel.invokeMethod(Method.IS_PUSH_ENABLED);
    return version;
  }

  static Future<String?> logOut(bool pushEnabled) async {
    final String? result =
        await _channel.invokeMethod(Method.LOGOUT_WITH_OPT_IN, [pushEnabled]);
    return result;
  }

  static Future<String?> setAlias(String alias) async {
    final String? version =
        await _channel.invokeMethod(Method.SET_ALIAS, [alias]);
    return version;
  }

  static Future<String> getAlias() async {
    final String alias = await _channel.invokeMethod(Method.GET_ALIAS);
    return alias;
  }

  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    final Map<String, dynamic>? deviceInfo =
        await _channel.invokeMapMethod<String, dynamic>(Method.GET_DEVICE_INFO);
    return deviceInfo;
  }

  static Future<String?> removeBadgeNumber() async {
    final String deviceInfo =
        await _channel.invokeMethod(Method.REMOVE_BADGE_NUMBER);
    return deviceInfo;
  }

  //InApp methods
  static Future<String?> triggerInApp(String value) async {
    final String returnValue =
        await _channel.invokeMethod(Method.TRIGGER_INAPP, [value]);
    return returnValue;
  }

  static Future<dynamic> fetchInboxMessage() async {
    final String returnValue =
        await _channel.invokeMethod(Method.FETCH_INBOX_MESSAGES);
    return returnValue;
  }

  static Future<String?> fetchInBoxMessageWithMessageId(int value) async {
    final String returnValue = await _channel
        .invokeMethod(Method.FETCH_INBOX_MESSAGES_WITH_ID, [value]);
    return returnValue;
  }

  static Future<bool> inAppMarkAsRead(String templateId, String eventId) async {
    return await _channel
        .invokeMethod(Method.INAPP_MARK_AS_READ, [templateId, eventId]);
  }

  static Future<bool> inAppMarkAsUnread(
      String templateId, String eventId) async {
    return await _channel
        .invokeMethod(Method.INAPP_MARK_AS_UNREAD, [templateId, eventId]);
  }

  static Future<bool> inAppMarkAsDeleted(
      String templateId, String eventId) async {
    return await _channel
        .invokeMethod(Method.INAPP_MARK_AS_DELETED, [templateId, eventId]);
  }

  static Future<Map<String, dynamic>?> getInitialMessage() async {
    final Map<String, dynamic>? message = await _channel
        .invokeMapMethod<String, dynamic>(Method.GET_INITIAL_MESSAGE);
    return message;
  }

  //geotargeting

  static Future<String> startGeoFencing() async {
    return await _channel.invokeMethod(Method.START_GEOFENCING);
  }

  static Future<String> stopGeoFencing() async {
    return await _channel.invokeMethod(Method.STOP_GEOFENCING);
  }

  /// Only for Android - Request permission to post notifications, for Android 13 and higher
  static Future<bool> requestPermissionPostNotifications() async {
    if (Platform.isIOS) {
      return true;
    } else {
      return await _channel
          .invokeMethod(Method.PERSMISSION_REQUEST_POST_NOTIFICATION);
    }
  }
}
