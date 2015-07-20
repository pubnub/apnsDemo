/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "DataManager.h"
#import <PubNub/PubNub.h>


#pragma mark Static

/**
 @brief  Stores reference on key which will be used by \b PubNub client to fetch data from \b PubNub
         network.
 */
static NSString * const kSubscribeKey = @"demo-36";

/**
 @brief  Stores reference on key which will be used by \b PubNub client to push data and changes
         to \b PubNub network.
 */
static NSString * const kPublishKey = @"demo-36";


#pragma mark - Private interface declaration

@interface DataManager () <PNObjectEventListener>


#pragma mark - Properties

/**
 @brief  Stores reference on initiated \b PubNub client used to communicate with \b PubNub network.
 */
@property (nonatomic, strong) PubNub *client;

/**
 @brief  Stores reference on device push token which can be used with \b PubNub SDK to register
         device to receive messages from specific channels using APNS.
 */
@property (nonatomic, copy) NSData *pushToken;

/**
 @brief  Stores list of listeners which would like to be notified when data manager state changed.
 */
@property (nonatomic, strong) NSHashTable *listeners;

/**
 @brief  Stores reference on queue which is used to serialize access to shared data manager
         information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Notification

/**
 @brief  Notify all listeners about device push notification modification.
 */
- (void)notifyAboutPushNotificationTokenChange;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation DataManager


#pragma mark - Initialization and configuration

- (instancetype)init {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        NSLog(@"Pub key: %@\nSub key: %@\nDev Console URL: http://www.pubnub.com/console?"
              "channel=apns&pub=%@&sub=%@", kPublishKey, kSubscribeKey, kPublishKey, kSubscribeKey);
        PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:kPublishKey
                                                                         subscribeKey:kSubscribeKey];
        _client = [PubNub clientWithConfiguration:configuration];
        [_client addListener:self];
        _listeners = [NSHashTable weakObjectsHashTable];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.example", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


#pragma mark - APNS information

- (NSData *)pushToken {
    
    __block NSData *pushToken = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
       
        pushToken = _pushToken;
    });
    
    return pushToken;
}

- (BOOL)enabledForAPNS {
    
    __block BOOL enabledForAPNS = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        
        enabledForAPNS = (_pushToken != nil);
    });
    
    return enabledForAPNS;
}

- (void)setDevicePushToken:(NSData *)token {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        NSLog(@"My device token is: %@", token);
        _pushToken = token;
        [self notifyAboutPushNotificationTokenChange];
    });
}

- (void)enablePushNotificationsWithCompletion:(void(^)(NSString *information))block {
    
    [self.client addPushNotificationsOnChannels:@[@"apns"] withDevicePushToken:self.pushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
        block(status.isError ? status.errorData.information : nil);
    }];
}

- (void)disablePushNotificationsWithCompletion:(void(^)(NSString *information))block {
    
    [self.client removePushNotificationsFromChannels:@[@"apns"] withDevicePushToken:self.pushToken
                                       andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
        block(status.isError ? status.errorData.information : nil);
    }];
}

- (void)disableAllPushNotificationsWithCompletion:(void(^)(NSString *information))block {
    
    [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.pushToken
                                                     andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
        block(status.isError ? status.errorData.information : nil);
    }];
}

- (void)auditPushNotificationsWithCompletion:(void(^)(NSArray *channels, NSString *information))block {
    
    [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.pushToken
                     andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                                      
        block((!status.isError ? result.data.channels : nil),
              (status.isError ? status.errorData.information : nil));
    }];
}


#pragma mark - Publish 

- (void)sendAPNSMessage:(NSString *)message toChannel:(NSString *)channel
         withCompletion:(void(^)(NSString *information))block {
    
    [self.client publish:nil toChannel:channel mobilePushPayload:@{@"aps":@{@"alert":message}}
          withCompletion:^(PNPublishStatus *status) {

        block(status.isError ? status.errorData.information : nil);
    }];
}


#pragma mark - Listeners

- (void)addListener:(id <DataManagerProtocol>)listener {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        [self.listeners addObject:listener];
    });
}

- (void)removeListener:(id <DataManagerProtocol>)listener {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        [self.listeners removeObject:listener];
    });
}


#pragma mark - PubNub events handler

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    __block NSArray *listeners = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        
        listeners = [[self.listeners allObjects] copy];
    });
    if ([client isEqual:self.client]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (id <DataManagerProtocol> listener in listeners) {
                
                if ([listener respondsToSelector:@selector(didReceiveMessage:onChannel:)]) {
                    
                    [listener didReceiveMessage:message.data.message
                                      onChannel:message.data.subscribedChannel];
                }
            }
        });
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    // Handle new presence event
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    
    // Handle client state change.
}


#pragma mark - Notifications

- (void)notifyAboutPushNotificationTokenChange {
    
    NSArray *listeners = [[self.listeners allObjects] copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (id <DataManagerProtocol> listener in listeners) {
            
            SEL selector = (_pushToken ? @selector(enabledForAPNS) : @selector(APNSEnableFailed));
            if ([listener respondsToSelector:selector]) {
                
                if (_pushToken) {
                    
                    [listener enabledForAPNS];
                }
                else {
                    
                    [listener APNSEnableFailed];
                }
            }
        }
    });
}

#pragma mark -


@end
