//
//  ResolutionService.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import Parse
import UIKit
import FBSDKCoreKit

class ResolutionService: NSObject
{
    func getActiveResolutions() -> NSMutableArray {
        var array:NSArray = []
        
        // try-except cloud function
        do {
            array = try PFCloud.callFunction("getPendingResolutions", withParameters: nil) as! NSArray
            
        } catch {
            // no op
        }
        
        let returnArray:NSMutableArray = []
        for item in array {
            let resolution:Resolution = getResolutionFromJSON(item as! NSDictionary)
            returnArray.addObject(resolution)
        }
        
        return returnArray
    }
    
    func saveResolution(title:String, comment:String, weeklyReminders:Int) ->String {
        // try-except cloud function in the background
        // return the id of the resolution object
        var objectId:String?
        do {
            objectId = try PFCloud.callFunction("saveResolution", withParameters: ["goalTitle":title, "comment":comment, "weeklyReminder":weeklyReminders]) as? String
            return objectId!
            
        } catch {
            // create resolution object
            return "noString"
        }
    }
    
    func updateResolution(resolution:Resolution) {
        do {
            try PFCloud.callFunction("editResolution", withParameters: ["goalTitle":resolution.title, "comment":resolution.comment, "weeklyReminder":resolution.weeklyUpdates, "objectId":resolution.id!])
        } catch {
            // no op
        }
    }
    
    func getQuote() ->String {
        var quote:String = ""
        
        do {
            quote = try PFCloud.callFunction("getQuote", withParameters: nil) as! String
            
        } catch {
            // no op
        }
        
        return quote
    }
    
    func deleteResolution(objectId:String) {
        do {
            try PFCloud.callFunction("deleteResolution", withParameters: ["objectId":objectId])
        } catch {
            // no op
        }
    }
    
    func getResolutionFromJSON(resolution:NSDictionary)->Resolution
    {
        let resolutionItem = Resolution()
        resolutionItem.title = resolution["title"] as! String
        resolutionItem.comment = resolution["comment"] as! String
        resolutionItem.createdAt = resolution["createdAt"] as! NSDate
        resolutionItem.weeklyUpdates = resolution["weeklyreminders"] as! Int
        resolutionItem.id = resolution["id"] as? String
        
        return resolutionItem
    }
    
    func getShareConfigText()
    {
        // get config sharetext
        PFConfig.getConfigInBackgroundWithBlock {
            (config: PFConfig?, error: NSError?) -> Void in
            let string = config?["shareText"] as? String
            
            // save to userdefaults
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(string, forKey: "shareText")
            prefs.synchronize()
        }
    }
    
    func getEmailFromFacebook(vc:UIViewController) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email"])
            request.startWithCompletionHandler({ (connection, result, error) -> Void in
                // place username with name, and check if email
                PFUser.currentUser()?.setValue(result["name"], forKey: "username")
                
                // we've accepted FB's name and email credentials
                if result["email"] != nil && PFUser.currentUser()?.objectForKey("email") == nil {
                    PFUser.currentUser()?.setValue(result["email"], forKey: "email")
                    PFUser.currentUser()?.setValue(true, forKey: "emailSettings")
                    PFUser.currentUser()?.saveInBackground()
                }

                // we must ask for user if no email
                else if result["email"] == nil && PFUser.currentUser()?.objectForKey("email") == nil{
                    // alert to prompt for email
                    let emailAlert = UIAlertController(title: "Email", message:"Enter your email to get a motivational weekly reminder!", preferredStyle: UIAlertControllerStyle.Alert)
                    emailAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                        textField.placeholder = "email"
                    })
                    
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                        PFUser.currentUser()?.setValue(emailAlert.textFields?.first?.text, forKey: "email")
                        PFUser.currentUser()?.setValue(true, forKey: "emailSettings")
                        PFUser.currentUser()?.saveInBackground()
                    })
                    let skip = UIAlertAction(title: "Skip", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
                        PFUser.currentUser()?.setValue(true, forKey: "emailSettings")
                        PFUser.currentUser()?.saveInBackground()
                    })
                    
                    // present alert controller
                    emailAlert.addAction(ok)
                    emailAlert.addAction(skip)
                    vc.presentViewController(emailAlert, animated: true, completion: nil)
                }
            })
        }
    }
}
