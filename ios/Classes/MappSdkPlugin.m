#import "MappSdkPlugin.h"
#import "PushMessageDelegate.h"
#import "InAppMessageDelegate.h"
#import "AppoxeeLocationManager.h"
#import "AppoxeeInappSDK.h"
#import "AppoxeeSDK.h"
#import "UserNotifications/UserNotifications.h"

static FlutterMethodChannel *channel;

@interface MappSdkPlugin ()

@property NSDictionary *initialMessage;
@property NSDictionary *lauchOptions;

@end

@implementation MappSdkPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"mapp_sdk"
            binaryMessenger:[registrar messenger]];
  MappSdkPlugin* instance = [[MappSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    // NSLog(@"==== SONO PRONTO PET IL LAUCHOPTIONS");
    _lauchOptions = launchOptions;
    
    return YES;
}



- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    // NSLog(@"%@",  response.notification.request.content.userInfo);
    
    NSString* title = response.notification.request.content.title;
    NSString* body = response.notification.request.content.body;
    NSDictionary* userInfo = response.notification.request.content.userInfo;
    NSString* media = [userInfo objectForKey:@"ios_apx_media"];
    NSString* dpl = [userInfo objectForKey:@"apx_dpl"];
    NSNumber* uniqueID = @([[userInfo objectForKey:@"apbcd"] intValue]);
    NSNumber *badge = [NSNumber numberWithInt:0];
    
    if ( dpl == nil ){
        dpl = @"";
    }
    
    if ( media == nil){
        media = @"";
    }
    
    NSDictionary<NSString *, id>* extraFields = @{
        @"ios_apx_media": media,
        @"apx_dpl": dpl
    };
    
    if ( title != nil && [title length] > 0 ){
        _initialMessage = @{
            @"id": uniqueID,
            @"title": title,
            @"alert": @"",
            @"body": body,
            @"badge": badge,
            @"subtitle": @"",
            @"category": @"",
            @"extraFields": extraFields,
            @"isRich": @"false",
            @"isSilent": @"false",
            @"isTriggerUpdate": @"false"
        };
    }
    
   [[Appoxee shared] userNotificationCenter:center didReceiveNotificationResponse:response withAppoxeeCompletionHandler:^{
           
        // When the completion handler is called, this means that Appoxee completed it's execution.
        // Call the completion handler.
        completionHandler();
    }];
    
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"engage" isEqualToString:call.method]){
    NSNumber* serverNumber = call.arguments[2];
    NSLog(@"server: %@", serverNumber);
      
    [[InAppMessageDelegate sharedObject] initWith:channel];
    [[InAppMessageDelegate sharedObject] addNotificationListeners];
    [[PushMessageDelegate sharedObject] initWith:channel];
    [[PushMessageDelegate sharedObject] addNotificationListeners];
    SERVER serv = [self getServerKeyFor:serverNumber];
    [[Appoxee shared] engageAndAutoIntegrateWithLaunchOptions:_lauchOptions andDelegate:(id)[PushMessageDelegate sharedObject] with:serv];
    INAPPSERVER inappServ = [self getInappServerKeyFor: serverNumber];
    [[AppoxeeInapp shared] engageWithDelegate:(id)[InAppMessageDelegate sharedObject] with:inappServ];
    // result(@"OK");
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:(id)[PushMessageDelegate sharedObject]];
    result([NSString stringWithFormat:@"%ld", (long)[Appoxee version]]);
  } else if ([@"postponeNotificationRequest" isEqualToString:call.method]){
    NSNumber *value = call.arguments[0];
    [[Appoxee shared] setPostponeNotificationRequest:[value boolValue]];
  } else if ([@"showNotificationsOnForeground" isEqualToString:call.method]){
    NSNumber *value = call.arguments[0];
    [[Appoxee shared] setShowNotificationsOnForeground:[value boolValue]];
  } else if ([@"isReady" isEqualToString:call.method]) {
    result([[Appoxee shared] isReady] ? @YES : @NO);
  } else if ([@"optIn" isEqualToString:call.method]){
    NSNumber *value = call.arguments[0];
    [[Appoxee shared] disablePushNotifications:![value boolValue] withCompletionHandler:NULL];
  } else if ([@"isPushEnabled" isEqualToString:call.method]){
    [[Appoxee shared] isPushEnabled:^(NSError * _Nullable appoxeeError, id  _Nullable data) {
        if (!appoxeeError) {
            BOOL state = [(NSNumber *)data boolValue];
            result((NSNumber *)data);
        } else {
          result(@NO);
        }
    }];
  } else if ([@"logoutWithOptin" isEqualToString:call.method]){
    NSNumber *value = call.arguments[0];
    [[Appoxee shared] logoutWithOptin:[value boolValue]];
  } else if ([@"setDeviceAlias" isEqualToString:call.method]){
    NSString* alias = call.arguments[0];
    [[Appoxee shared] setDeviceAlias:alias withCompletionHandler:NULL];
  } else if ([@"getDeviceAlias" isEqualToString:call.method]){
    [[Appoxee shared] getDeviceAliasWithCompletionHandler:^(NSError * _Nullable appoxeeError, id  _Nullable data) {
        if (!appoxeeError && [data isKindOfClass:[NSString class]])
        {
            NSString *deviceAlias = (NSString *)data;
            result(deviceAlias);
        } else {
          result(@"Error while getting alias!");
        }
    }];
  } else if ([@"fetchDeviceTags" isEqualToString:call.method]){
    [[Appoxee shared] fetchDeviceTags:^(NSError * _Nullable appoxeeError, id  _Nullable data) {
        if (!appoxeeError && [data isKindOfClass:[NSArray class]]) {
            NSArray *deviceTags = (NSArray *)data;
            result(deviceTags);
        }
    }];
  } else if ([@"fetchApplicationTags" isEqualToString:call.method]){
    [[Appoxee shared] fetchApplicationTags:^(NSError * _Nullable appoxeeError, id  _Nullable data) {
        if (!appoxeeError && [data isKindOfClass:[NSArray class]]) {
            NSArray *applicationTags = (NSArray *)data;
            result(applicationTags);
        }
    }];
  } else if ([@"addTagsToDevice" isEqualToString:call.method]){
    NSArray<NSString *> * tags = call.arguments[0];
    [[Appoxee shared] addTagsToDevice:tags withCompletionHandler:NULL];
  } else if ([@"removeTagsFromDevice" isEqualToString:call.method]){
    NSArray<NSString *> * tags = call.arguments[0];
    [[Appoxee shared] removeTagsFromDevice:tags withCompletionHandler:NULL];
  } else if ([@"setDateValueWithKey" isEqualToString:call.method]){
    NSDate* date = call.arguments[0];
    NSString* key = call.arguments[1];
    [[Appoxee shared] setDateValue:date forKey:key withCompletionHandler:NULL];
  } else if ([@"setNumberValueWithKey" isEqualToString:call.method]){
    NSNumber* number = call.arguments[1];
    NSString* key = call.arguments[0];
    [[Appoxee shared] setNumberValue:number forKey:key withCompletionHandler:NULL];
  } else if ([@"incrementNumericKey" isEqualToString:call.method]){
    NSNumber* number = call.arguments[1];
    NSString* key = call.arguments[0];
    [[Appoxee shared] incrementNumericKey:key byNumericValue:number withCompletionHandler:NULL];
  } else if ([@"setStringValueWithKey" isEqualToString:call.method]){
    NSString* stringValue = call.arguments[1];
    NSString* key = call.arguments[0];
    [[Appoxee shared] setStringValue:stringValue forKey:key withCompletionHandler:NULL];
  } else if ([@"fetchCustomFieldByKey" isEqualToString:call.method]){
    NSString* key = call.arguments[0];
    [[Appoxee shared] fetchCustomFieldByKey:key withCompletionHandler:^(NSError * _Nullable appoxeeError, id  _Nullable data) {
        if (!appoxeeError && [data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)data; NSString *key = [[dictionary allKeys] firstObject];
            id value = dictionary[key]; // can be of the following types: NSString || NSNumber || NSDate }
        // If there wan't an error, and data object is nil, then value doesn't exist on the device.
        }
    }];
  } else if ([@"getDeviceInfo" isEqualToString:call.method]){
    APXClientDevice* device = [[Appoxee shared] deviceInfo];
    NSDictionary *deviceData = [self deviceInfo:device];
    result(deviceData);
  } else if ([@"removeBadgeNumber" isEqualToString:call.method]){
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  } else if ([@"addTagsToDevice" isEqualToString:call.method]){
    NSArray<NSString *> * array = call.arguments[0];
    [[Appoxee shared] addTagsToDevice:array withCompletionHandler:NULL];
  } else if ([@"removeTagsFromDevice" isEqualToString:call.method]){
    NSArray<NSString *> * array = call.arguments[0];
    [[Appoxee shared] removeTagsFromDevice:array withCompletionHandler:NULL];
  } else if ([@"triggerInApp" isEqualToString:call.method]){
    NSString * eventName = call.arguments[0];
    [[AppoxeeInapp shared]reportInteractionEventWithName: eventName andAttributes:NULL];
  } else if ([@"fetchInboxMessage" isEqualToString:call.method]){
    [[AppoxeeInapp shared] fetchAPXInBoxMessages];
    NSLog(@"This is fetchAPXInBox");
  } else if ([@"fetchInBoxMessageWithMessageId" isEqualToString:call.method]){
    NSNumber * messageId = call.arguments[0];
    [[AppoxeeInapp shared] fetchInBoxMessageWithMessageId:[messageId stringValue]];
    NSLog(@"This is fetchInBoxMessageWithMessageId");
  } else if ([@"startGeofencing" isEqualToString:call.method]){
    [[AppoxeeLocationManager shared] setLogLevel:1];
    [[AppoxeeLocationManager shared] enableLocationMonitoring];
    NSLog(@"GeoFencing started!");
    result(@"GEOFENCES_STARTED_OK");
  } else if ([@"stopGeofencing" isEqualToString:call.method]){
    [[AppoxeeLocationManager shared] disableLocationMonitoring];
    NSLog(@"Geofencing stopped!");
    result(@"GEOFENCES_STOPPED_OK");
  } else if ([@"getInitialMessage" isEqualToString:call.method]){
    NSLog(@"getInitialMessage...");
      NSLog(@"%@", _initialMessage);
      result(_initialMessage);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *) deviceInfo: (APXClientDevice *) device {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject: device.udid forKey:@"udid"];
    [dict setObject: device.sdkVersion forKey:@"sdkVersion"];
    [dict setObject:device.locale forKey:@"locale"];
    [dict setObject:device.timeZone forKey:@"timezone"];
    [dict setObject:device.hardwearType forKey:@"deviceModel"];
    [dict setObject:device.osVersion forKey:@"osVersion"];
    [dict setObject:device.osName forKey:@"osName"];
    return dict;
}

-(UIViewController* ) topViewController: (UIViewController* ) base {
    if ([base isKindOfClass:UINavigationController.class]) {
        UINavigationController* nav  = (UINavigationController*) base;
        return [self topViewController:[nav visibleViewController]];
    }
    if ([base isKindOfClass:UITabBarController.class]) {
        UITabBarController* tab = (UITabBarController*) base;
        UIViewController* selected = [tab selectedViewController];
        if (selected) {
            return [self topViewController:selected];
        }
    }
    UIViewController* presented = [base presentedViewController];
    if (presented) {
        return [self topViewController:presented];
    }
    return base;
}

- (SERVER)getServerKeyFor: (NSNumber *) name {
    if ([name intValue] == 0) {
        return L3;
    }
    if ( [name intValue] == 2) {
        return EMC;
    }
    if ( [name intValue] == 3) {
        return EMC_US;
    }
    if ( [name intValue] == 4) {
        return CROC;
    }
    if ([name intValue] == 5) {
        return TEST;
    }
    if ([name intValue] == 6) {
        return TEST55;
    }
    return TEST;
}

- (INAPPSERVER) getInappServerKeyFor: (NSNumber *) name {
    if ([name intValue] == 0) {
        return l3;
    }
    if ( [name intValue] == 2) {
        return eMC;
    }
    if ( [name intValue] == 3) {
        return eMC_US;
    }
    if ( [name intValue] == 4) {
        return cROC;
    }
    if ([name intValue] == 5) {
        return tEST;
    }
    if ([name intValue] == 6) {
        return tEST55;
    }
    return tEST;
}

@end
