#import <Foundation/Foundation.h>

/**
 @brief  Declare interface which can be used by data consumers to be notified about changes in 
         data manager.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol DataManagerProtocol <NSObject>


///------------------------------------------------
/// @name Push notification information
///------------------------------------------------

/**
 @brief  Called on listener when application successfully received push notification token and can
         accept push notifications.
 */
- (void)enabledForAPNS;

/**
 @brief  Called on listener when application failed to received push notification token and can't
         accept push notifications.
 */
- (void)APNSEnableFailed;


///------------------------------------------------
/// @name Real-time network
///------------------------------------------------

/**
 @brief  Called on listener when there is new message arrived from real-time network.
 
 @param message Reference on message object which has been received.
 @param channel Name of the channel on which message has been received.
 */
- (void)didReceiveMessage:(id)message onChannel:(NSString *)channel;

#pragma mark -


@end
