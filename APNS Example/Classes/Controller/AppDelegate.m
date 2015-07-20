/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "AppDelegate.h"
#import "ViewController.h"
#import "DataManager.h"


#pragma mark Private interface declaration

@interface AppDelegate ()


#pragma mark - Properties

/**
 @brief      Stores reference on data manipulation helper object.
 @discussion This object used by application to manage internal state and as layer between real-time
             communication network and application code.
 */
@property (nonatomic) DataManager *manager;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation AppDelegate


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Instantiate data manager and pass reference to root view controller.
    self.manager = [DataManager new];
    [(ViewController *)self.window.rootViewController setDataManager:self.manager];
    
#if !TARGET_IPHONE_SIMULATOR
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // Registering for push notifications under iOS8
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        
        // Register for push notifications for pre-iOS8
        UIRemoteNotificationType type = (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
#endif

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [self.manager setDevicePushToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [self.manager setDevicePushToken:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"aps"];
    if ([alert isKindOfClass:[NSString class]]) {
        
        message = alert;
    }
    else if ([alert isKindOfClass:[NSDictionary class]]) {
        
        message = [alert objectForKey:@"alert"];
    }
    
    if (alert) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:@"is the message."
                                                           delegate:self cancelButtonTitle:@"Yeah PubNub!"
                                                  otherButtonTitles:@"Cool PubNub!", nil];
        [alertView show];
    }
}

#pragma mark -


@end
