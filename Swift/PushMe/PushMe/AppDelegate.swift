//
//  AppDelegate.swift
//  PushMe
//
//  Created by Jordan Zucker on 8/6/15.
//  Copyright (c) 2015 TestAPNS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    
    lazy var client: PubNub = {
        let config = PNConfiguration(publishKey: "<your pub key>", subscribeKey: "<your sub key>")
        return PubNub.clientWithConfiguration(config)
        } ()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        client.addListener(self)
        client.subscribeToChannels(["testAPNS"], withPresence: true)
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: "DeviceToken")
        client.addPushNotificationsOnChannels(["testAPNS"], withDevicePushToken: deviceToken) { (status) -> Void in
            println("\(status.debugDescription)")
            self.client.publish("what what", toChannel: "testAPNS", mobilePushPayload: ["aps" : ["alert" : "To Apple and PN native devices! (on swift)"]], withCompletion: { (status) -> Void in
                println("\(status.debugDescription)")
            })
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("didFail!")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("remote")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        
    }
    
    func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        
    }


}

