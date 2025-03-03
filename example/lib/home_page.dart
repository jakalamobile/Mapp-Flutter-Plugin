import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mapp_sdk_example/deep_link_page.dart';
import 'package:mapp_sdk/mapp_sdk.dart';
import 'package:mapp_sdk/helper_classes.dart';

class Config {
  static const String sdkKey = "183408d0cd3632.83592719";
  static const String appID = "206974";
  static const String googleProjectId = "785651527831";
  static const String tenantID = "5963";
  static const SERVER server = SERVER.L3;
}

// class Config {
//   static const String sdkKey = "187b8432cc7644.91361308";
//   static const String appID = "207036";
//   static const String googleProjectId = "498892612269";
//   static const String tenantID = "5963";
//   static const SERVER server = SERVER.L3;
// }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _aliasToSetString = '';
  String? _tagToSetString = '';
  String? _tagToRemoveString = '';
  String? _stringToSetString = '';
  String? _attributeToGetString = '';
  String? _stringToRemoveString = '';

  List<String> _screens = [];

  @override
  void initState() {
    debugPrint("initState()");
    super.initState();

    initMappSdk();
  }

  void initMappSdk() async {
    debugPrint("initMappSdk()");
    await MappSdk.engage(Config.sdkKey, Config.googleProjectId, Config.server,
        Config.appID, Config.tenantID);
    await initPlatformState();
    await requestPermissionPostNotifications();
    await MappSdk.showNotificationsOnForeground(true);
  }

  void handledRemoteNotification(dynamic arguments) {
    print("handle remote notification!");
    print(arguments);
  }

  void didReceiveDeepLinkWithIdentifierHandler(dynamic arguments) {
    print("deep link received!");
    print(arguments);
    HashMap<String, dynamic> map = HashMap.from(arguments);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeepLinkPage(map: map)),
    );
  }

  void didReceiveInappMessageWithIdentifierHandler(dynamic arguments) {
    print("Inapp message received!");
    print(arguments);
  }

  void didReceiveCustomLinkWithIdentifierHandler(dynamic arguments) {
    print("Custom Link With Identifier received!");
    print(arguments);
  }

  void didReceiveInBoxMessagesHandler(dynamic arguments) {
    print("Inbox Messages received!");
    print(arguments);
    _showMyDialog("Inbox messages", "", jsonEncode(arguments));
  }

  void inAppCallFailedWithResponseHandler(dynamic arguments) {
    print("inApp Call Failed received!");
    print(arguments);
  }

  void didReceiveInBoxMessageHandler(dynamic arguments) {
    print("Inbox Message received!");
    print(arguments);
  }

  void remoteNotificationHandler(dynamic arguments) {
    print("remote Notification received!");
    print(arguments);
  }

  void richContentHandler(dynamic arguments) {
    print("rich Content received!");
    print(arguments);
  }

  void pushOpenedHandler(dynamic arguments) {
    print("Push opened!");
    print(arguments);
  }

  void pushDismissedHandler(dynamic arguments) {
    print("Push dismissed!");
    print(arguments);
  }

  void pushSilentHandler(dynamic arguments) {
    print("Push silent!");
    print(arguments);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _screens = [
        "Set Device Alias Text",
        "Set Device Alias",
        "Get Device Alias",
        "Device Information",
        "Is Push Enabled",
        "Opt in",
        "Opt out",
        "Fetch inbox messages",
        "In App: App Open",
        "In App: App Feedback",
        "In App: App Discount",
        "In App: App Promo",
        "Remove Badge Number",
        "Lock Orientation",
        "Engage",
        "Log out",
        "Log out (& optOut)",
        "Start Geo",
        "Stop Geo"
      ];
    });
  }

  Future<void> requestPermissionPostNotifications() async {
    try {
      final result = await MappSdk.requestPermissionPostNotifications();
      debugPrint("POST NOTIFICATION PERMISSION RESULT: " + result.toString());
      if (!result) {
        _showMyDialog(
            "POST NOTIFICATION", "Permission result", "Permission was denied!");
      }
    } on PlatformException catch (e) {
      _showMyDialog("POST NOTIFICATION", e.code,
          e.message?.toString() ?? "Unknown error");
    }
  }

  Future<void> _showMyDialog(String title, String subtitle, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(subtitle),
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final textHolder = TextEditingController(text: '');

  clearText() {
    textHolder.clear();
  }

  Card _createTextFieldOrButton(int index) {
    switch (index) {
      case 0:
        return Card(
          child: TextFormField(
            controller: textHolder,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Enter alias'),
            onChanged: (String? value) {
              _aliasToSetString = value?.trim();
            },
          ),
        );
      default:
        return Card(
          child: ListTile(
            title: Text(
              _screens[index],
              style: TextStyle(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              onTap(index);
            },
          ),
        );
    }
  }

  void onTap(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_screens[index] == "Engage") {
      MappSdk.engage(Config.sdkKey, Config.googleProjectId, Config.server,
          Config.appID, Config.tenantID);
      print(
          "ENGAGE WITH PARAMS: SDK_KEY: ${Config.sdkKey}, Server: ${Config.server.toString()}, APP_ID: ${Config.appID}, TENANT_ID: ${Config.tenantID}");
    } else if (_screens[index] == "Set Device Alias") {
      if (_aliasToSetString?.isNotEmpty ?? false) {
        MappSdk.setAlias(_aliasToSetString!).then((value) => clearText());
      } else {
        _showMyDialog('Alias', "Not set", "Alias can't be empty");
      }
    } else if (_screens[index] == "Get Device Alias") {
      MappSdk.getAlias().then(
          (String value) => {_showMyDialog("Show Alias", "Alias:", value)});
    } else if (_screens[index] == "Device Information") {
      String data = '';
      MappSdk.getDeviceInfo().then((Map<String, dynamic>? map) {
        data = map != null ? jsonEncode(map) : "null";
        _showMyDialog("Device info", "", data);
      });
    } else if (_screens[index] == "Is Push Enabled") {
      MappSdk.isPushEnabled().then((bool value) =>
          {_showMyDialog("Push Enabled", "", value ? "YES" : "NO")});
    } else if (_screens[index] == "Opt in") {
      MappSdk.setPushEnabled(true);
    } else if (_screens[index] == "Opt out") {
      MappSdk.setPushEnabled(false);
    } else if (_screens[index] == "Remove Badge Number") {
      MappSdk.removeBadgeNumber();
    } else if (_screens[index] == "Log out") {
      MappSdk.logOut(true).then((String? result) => print(result ?? "unknown"));
    } else if (_screens[index] == "Log out (& optOut)") {
      MappSdk.logOut(false)
          .then((String? result) => print(result ?? "unknown"));
    } else if (_screens[index] == "In App: App Open") {
      MappSdk.triggerInApp("app_open");
    } else if (_screens[index] == "Fetch inbox messages") {
      if (Platform.isAndroid) {
        MappSdk.fetchInboxMessage().then((value) {
          print(value);
          _showMyDialog("Inbox messages", "", value);
        });
      } else {
        MappSdk.fetchInboxMessage();
      }
    } else if (_screens[index] == "In App: App Feedback") {
      //FetchInBox se koristi samo za testiranje
      // MappSdk.fetchInBoxMessageWithMessageId(18870);
      MappSdk.triggerInApp("app_feedback");
    } else if (_screens[index] == "In App: App Discount") {
      MappSdk.triggerInApp("app_discount");
    } else if (_screens[index] == "In App: App Promo") {
      MappSdk.triggerInApp("app_promo");
    } else if (_screens[index] == "Start Geo") {
      MappSdk.startGeoFencing().then((status) {
        debugPrint("Start Geofencing status:" + status);
        _showMyDialog("Start Geofencing", "", status);
      }).catchError((e) {
        debugPrint("Start Geofencing error:" + e.toString());
        _showMyDialog("Start Geofencing", "", e.to);
      });
    } else if (_screens[index] == "Stop Geo") {
      MappSdk.stopGeoFencing().then((status) {
        debugPrint("Stop Geofencing status:" + status);
        _showMyDialog("Stop Geofencing", "", status);
      }).catchError((e) {
        debugPrint("Stop Geofencing error:" + e.toString());
        _showMyDialog("Stop Geofencing", "", e.toString());
      });
    }
  }

  ListView _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: _screens.length,
      itemBuilder: (context, index) {
        return _createTextFieldOrButton(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MappSdk.didReceiveDeepLinkWithIdentifier = (dynamic arguments) =>
        didReceiveDeepLinkWithIdentifierHandler(arguments);

    MappSdk.didReceiveInappMessageWithIdentifier = (dynamic arguments) =>
        didReceiveInappMessageWithIdentifierHandler(arguments);

    MappSdk.didReceiveCustomLinkWithIdentifier = (dynamic arguments) =>
        didReceiveCustomLinkWithIdentifierHandler(arguments);

    MappSdk.didReceiveInBoxMessages =
        (dynamic arguments) => didReceiveInBoxMessagesHandler(arguments);

    MappSdk.inAppCallFailedWithResponse =
        (dynamic arguments) => inAppCallFailedWithResponseHandler(arguments);

    MappSdk.didReceiveInBoxMessage =
        (dynamic arguments) => didReceiveInBoxMessageHandler(arguments);

    MappSdk.handledRemoteNotification =
        (dynamic arguments) => remoteNotificationHandler(arguments);

    MappSdk.handledRichContent =
        (dynamic arguments) => richContentHandler(arguments);

    MappSdk.handledPushOpen =
        (dynamic arguments) => pushOpenedHandler(arguments);

    MappSdk.handledPushDismiss =
        (dynamic arguments) => pushDismissedHandler(arguments);

    MappSdk.handledPushSilent =
        (dynamic arguments) => pushSilentHandler(arguments);

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Mapp SDK Demo'),
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          body: _buildListView(context)),
    );
  }
}
