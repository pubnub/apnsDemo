#import <UIKit/UIKit.h>


#pragma mark Class forward

@class DataManager;


/**
 @brief  Class which is used to display main view for simple subscribe application.
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface ViewController : UIViewController


///------------------------------------------------
/// @name Data provider
///------------------------------------------------

/**
 @brief  Allow to specify data providing object which sbould be used during interaction with user.
 
 @param manager Reference on initialized and ready to use data manager instance.
 */
- (void)setDataManager:(DataManager *)manager;

#pragma mark -


@end

