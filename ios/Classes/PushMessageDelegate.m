//  Created by Stefan Stevanovic on 9.12.21..
//

#import "PushMessageDelegate.h"
#import <UIKit/UIKit.h>
#import "AppoxeeSDK.h"

@interface PushMessageDelegate() <AppoxeeDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property FlutterMethodChannel* channel;

@end

@implementation PushMessageDelegate

+ (PushMessageDelegate *)sharedObject {
    static PushMessageDelegate *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (void)initWith:(FlutterMethodChannel *)channel {
    self.channel = channel;
    NSLog(@"Push Delegate init done!");
}

- (void)addNotificationListeners {
    NSLog(@"Listeners will be added!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"handledRemoteNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(remoteNotificationHandler:) name:@"handledRemoteNotification" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"handledRichContent" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(richContentHandler:) name:@"handledRichContent" object:nil];

}

//selectors to forward data to flutter level
- (void)remoteNotificationHandler:(NSNotification *)notification {
    NSLog(@"notification reveived in remote notification with identifier %@!", notification);
    [self.channel invokeMethod:@"handledRemoteNotification" arguments:notification.userInfo];
}

- (void)richContentHandler:(NSNotification *)notification {
    NSLog(@"notification reveived with rich content %@!", notification);
    [self.channel invokeMethod:@"handledRichContent" arguments:notification.userInfo];
}

//delegate method
- (void)appoxee:(Appoxee *)appoxee handledRemoteNotification:(APXPushNotification *)pushNotification andIdentifer:(NSString *)actionIdentifier {
    if ([self getPushMessage:pushNotification]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:
             @"handledRemoteNotification" object:nil userInfo:[self getPushMessage:pushNotification]];
    }
    NSString* deepLink = pushNotification.extraFields[@"apx_dpl"];
    if (deepLink && ![deepLink isEqualToString:@""] && actionIdentifier) {
        [[NSNotificationCenter defaultCenter] postNotificationName:
            @"didReceiveDeepLinkWithIdentifier" object:nil userInfo: @{@"action":actionIdentifier, @"url": deepLink, @"event_trigger": @"" }];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:
             @"handledRemoteNotification" object:nil userInfo:notification.request.content.userInfo];
    if ([[Appoxee shared] showNotificationsOnForeground]) {
        if (completionHandler) completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    } else {
        if (completionHandler) completionHandler(UNNotificationPresentationOptionNone);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [[Appoxee shared] userNotificationCenter:center didReceiveNotificationResponse:response withAppoxeeCompletionHandler:^{

            completionHandler();
        }];
}

- (void)appoxee:(Appoxee *)appoxee handledRichContent:(APXRichMessage *)richMessage didLaunchApp:(BOOL)didLaunch {
    NSLog(@"notification reveived with %@ and it will be propagate!", [self getRichMessage:richMessage]);
    if ([self getRichMessage:richMessage]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:
             @"handledRichContent" object:nil userInfo:[self getRichMessage:richMessage]];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"remote silent notification %@", userInfo);
}

-(NSDictionary *) getPushMessage: (APXPushNotification *) pushMessage {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (pushMessage.title)
        [dict setObject:pushMessage.title forKey:@"title"];
    if (pushMessage.alert)
        [dict setObject:pushMessage.alert forKey:@"alert"];
    if (pushMessage.body)
        [dict setObject:pushMessage.body forKey:@"body"];
    if (pushMessage.uniqueID)
        [dict setObject:[NSNumber numberWithInteger: pushMessage.uniqueID] forKey: @"id"];
    if (pushMessage.badge)
        [dict setObject:[NSNumber numberWithInteger: pushMessage.badge] forKey: @"badge"];
    if (pushMessage.subtitle)
        [dict setObject:pushMessage.subtitle forKey:@"subtitle"];
    if (pushMessage.pushAction.categoryName)
        [dict setObject:pushMessage.pushAction.categoryName forKey:@"category" ];
    if (pushMessage.extraFields)
        [dict setObject:pushMessage.extraFields forKey:@"extraFields"];
    if (pushMessage.isRich)
        [dict setObject:pushMessage.isRich ? @"true": @"false" forKey:@"isRich"];
    if (pushMessage.isSilent)
        [dict setObject:pushMessage.isSilent ? @"true": @"false" forKey:@"isSilent"];
    if (pushMessage.isTriggerUpdate)
        [dict setObject:pushMessage.isTriggerUpdate ? @"true": @"false" forKey:@"isTriggerUpdate"];
    return dict;
}

-(NSDictionary *) getRichMessage: (APXRichMessage *) message {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(message.uniqueID)
        [dict setObject:[[NSNumber numberWithInteger:message.uniqueID] stringValue] forKey:@"id"];
    if(message.title)
        [dict setObject:message.title forKey:@"title"];
    if(message.content)
        [dict setObject:message.content forKey:@"content"];
    if(message.messageLink)
        [dict setObject:message.messageLink forKey:@"messageLink"];
    if(message.postDate)
        [dict setObject:[self stringFromDate: message.postDate inUTC:false] forKey:@"postDate"];
    if(message.postDateUTC)
        [dict setObject:[self stringFromDate: message.postDateUTC inUTC:true] forKey:@"postDateUTC"];
    if(message.isRead)
        [dict setObject:[NSNumber numberWithBool:message.isRead] forKey:@"isRead"];
    return dict;

}

- (NSString *)stringFromDate:(NSDate *)date inUTC: (BOOL) isUTC{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (isUTC) {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

@end
