#import <Foundation/Foundation.h>
#import "DataManagerProtocol.h"


/**
 @brief  Class used as intermediate layer between application code and real-time network 
         communication.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface DataManager : NSObject


///------------------------------------------------
/// @name APNS information
///------------------------------------------------

/**
 @brief  Check whether application ready for push notifications or not.
 
 @return \c YES in case if data manager has valid device push token stored.
 */
- (BOOL)enabledForAPNS;

/**
 @brief  Uodate device push token which should be used to register for remote push notifications.
 
 @param token Reference on device push token which has been received by application delegate.
 */
- (void)setDevicePushToken:(NSData *)token;

/**
 @brief  Enable push notification on default channel.
 
 @param block Reference on block which will be called at the end of push notificaiton enable
              process. Block pass only one parameter - error description.
 */
- (void)enablePushNotificationsWithCompletion:(void(^)(NSString *information))block;

/**
 @brief  Disable push notification on default channel.
 
 @param block Reference on block which will be called at the end of push notificaiton disable
              process. Block pass only one parameter - error description.
 */
- (void)disablePushNotificationsWithCompletion:(void(^)(NSString *information))block;

/**
 @brief  Disable all push notifications on default channel.
 
 @param block Reference on block which will be called at the end of push notificaiton disable
              process. Block pass only one parameter - error description.
 */
- (void)disableAllPushNotificationsWithCompletion:(void(^)(NSString *information))block;

/**
 @brief  Audit push notification enabled channels.
 
 @param block Reference on block which will be called at the end of push notificaiton enabled
              channels audit process. Block pass two parameters: \c channels - list of channels for
              which push notifications has been enabled; information - error description.
 */
- (void)auditPushNotificationsWithCompletion:(void(^)(NSArray *channels, NSString *information))block;


///------------------------------------------------
/// @name Publish
///------------------------------------------------

/**
 @brief  Send \c message to \c channel as APNS.
 
 @param message Reference on object which should be pushed to \b PubNub network.
 @param channel Reference on name of the channel to which message should be sent.
 @param block   Reference on block which will be called at the end of message publishing process and
                pass only one parameter - error description.
 */
- (void)sendAPNSMessage:(NSString *)message toChannel:(NSString *)channel
         withCompletion:(void(^)(NSString *information))block;


///------------------------------------------------
/// @name Listeners
///------------------------------------------------

/**
 @brief  Add one more listener which would like to receive updated about manager state changes.
 
 @param listener Reference on instance which conform to \b DataManagerProtocol and would like to
                 receive state updates.
 */
- (void)addListener:(id <DataManagerProtocol>)listener;

/**
 @brief  Remove listener from list of instances which will receive manager state changes.
 
 @param listener Reference on instance which conform to \b DataManagerProtocol and doesn't want to 
                 receive any updates anymore.
 */
- (void)removeListener:(id <DataManagerProtocol>)listener;

#pragma mark - 


@end
