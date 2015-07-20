/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "ViewController.h"
#import "DataManager.h"


#pragma mark Private interface declaration

@interface ViewController () <DataManagerProtocol>


#pragma mark - Properties

/**
 @brief  Stores reference on list of buttons which activity state depends on whether application
         ready to work with APNS or not.
 */
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

/**
 @brief  Stores reference on text view which is used to notify about operation processing status.
 */
@property (nonatomic, weak) IBOutlet UITextView *operationStatus;

/**
 @brief      Stores reference on data manipulation helper object.
 @discussion This object used by application to manage internal state and as layer between real-time
             communication network and application code.
 */
@property (nonatomic, strong) DataManager *manager;


#pragma mark - Interface

/**
 @brief  Use latest data manager state information to update elements layout.
 */
- (void)updateInterface;

/**
 @brief  Display results of recently performed operation to the user.
 
 @param message          Reference on string which should be shown to the user.
 @param errorDescription Reference on string which describe error reason.
 */
- (void)showStatusMessage:(NSString *)message error:(NSString *)errorDescription;


#pragma mark - Handlers

/**
 @brief  Handle user tap on 'publish message' button.
 
 @param sender Reference on button which has been tapped by user.
 */
- (IBAction)handlePublishButtonTap:(id)sender;

/**
 @brief  Handle user tap on 'enable push notifications' button.
 
 @param sender Reference on button which has been tapped by user.
 */
- (IBAction)handleEnablePushButtonTap:(id)sender;

/**
 @brief  Handle user tap on 'disable push notifications' button.
 
 @param sender Reference on button which has been tapped by user.
 */
- (IBAction)handleDisablePushButtonTap:(id)sender;

/**
 @brief  Handle user tap on 'disable all push notifications' button.
 
 @param sender Reference on button which has been tapped by user.
 */
- (IBAction)handleDisableAllPushButtonTap:(id)sender;

/**
 @brief  Handle user tap on 'audit push notifications' button.
 
 @param sender Reference on button which has been tapped by user.
 */
- (IBAction)handleRequestPushEnabledButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation ViewController


#pragma mark - Controller life-cycle

- (void)viewDidLoad {
    
    // Forward method call to the super class.
    [super viewDidLoad];
    
    [self updateInterface];
}


#pragma mark - Interface

- (void)updateInterface {
    
    for (UIButton *button in self.buttons) {
        
        button.enabled = [self.manager enabledForAPNS];
    }
}

- (void)showStatusMessage:(NSString *)message error:(NSString *)errorDescription {
    
    self.operationStatus.text = [message stringByAppendingString:(errorDescription?: @"")];
}


#pragma mark - Data provider

- (void)setDataManager:(DataManager *)manager {
    
    self.manager = manager;
    [self.manager addListener:self];
    [self updateInterface];
}


#pragma mark - Handlers

- (IBAction)handlePublishButtonTap:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager sendAPNSMessage:@"Greetz from APNS" toChannel:@"apns"
                   withCompletion:^(NSString *information) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf showStatusMessage:(!information ? @"Message published to 'apns'." :
                                       @"Message publish diud failed: ") error:information];
    }];
}

- (IBAction)handleEnablePushButtonTap:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager enablePushNotificationsWithCompletion:^(NSString *information) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf showStatusMessage:(!information ? @"Push notifications enabled on 'apns'." :
                                       @"Push notification enable did fail: ")
                                error:information];
    }];
}

- (IBAction)handleDisablePushButtonTap:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager disablePushNotificationsWithCompletion:^(NSString *information) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf showStatusMessage:(!information ? @"Push notifications disabled on 'apns'." :
                                       @"Push notification disable did fail: ")
                                error:information];
    }];
}

- (IBAction)handleDisableAllPushButtonTap:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager disableAllPushNotificationsWithCompletion:^(NSString *information) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf showStatusMessage:(!information ? @"All push notifications disabled." :
                                       @"All push notification disable did fail: ")
                                error:information];
    }];
}

- (IBAction)handleRequestPushEnabledButtonTap:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [self.manager auditPushNotificationsWithCompletion:^(NSArray *channels, NSString *information) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *channlesList = ([channels count] ? [channels componentsJoinedByString:@", "] : @"<empty>");
        [strongSelf showStatusMessage:(!information ?
                                       [NSString stringWithFormat:@"Push notification enabled on: %@.",
                                        channlesList] :
                                       @"Push notification enabled channeld audit did fail: ")
                                error:information];
    }];
}

- (void)enabledForAPNS {
    
    [self updateInterface];
}

- (void)APNSEnableFailed {
    
    [self updateInterface];
}

- (void)didReceiveMessage:(id)message onChannel:(NSString *)channel {
    
    NSLog(@"I got a message!: %@", message);
}

#pragma mark -


@end
