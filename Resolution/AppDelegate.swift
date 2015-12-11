//
//  AppDelegate.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // grab keys from xconfig
        var info = NSBundle.mainBundle().infoDictionary
        let parseClientId = info!["ParseClientId"]!
        let parseClientSecret = info!["ParseClientSecret"]!
        
        // Initialize Parse
        Parse.setApplicationId(parseClientId as! String, clientKey:parseClientSecret as! String);
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // initizlize fb
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // push
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    /////////////////////
    // push notification setup
    /////////////////////
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // no op
    }
    
    
    /////////////////////
    // unused
    /////////////////////
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }



}

