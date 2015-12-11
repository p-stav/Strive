//
//  HelperService.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit
import Parse

class HelperService: NSObject, UIActionSheetDelegate
{
    
    func presentFailedSaveAlert(vc:UIViewController)
    {
        // present alert
        let alert = UIAlertController(title: "Doh!", message: "Don't forget to add a title or description!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil)
        alert.addAction(alertOK)
        
        vc.presentViewController(alert, animated:false, completion: nil)

    }
    
    func presentDeleteResolution(objectId:String, vc:UIViewController)
    {
        // present alert
        let alert = UIAlertController(title: "Delete this goal?", message:nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertOK = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alert:UIAlertAction!) -> Void in
            // delete resolution
            dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
                ResolutionService().deleteResolution(objectId)
            }
            
            // post notification
            NSNotificationCenter.defaultCenter().postNotificationName("removeResolution", object: objectId)
            
            // pop viewcontroller
            vc.navigationController?.popViewControllerAnimated(true)
            
        }
        let alertCancel = UIAlertAction(title:"cancel", style:UIAlertActionStyle.Cancel, handler:nil)
        
        alert.addAction(alertOK)
        alert.addAction(alertCancel)
        
        vc.presentViewController(alert, animated:false, completion: nil)
    }
    
    func presentShareDialog (vc:UIViewController, goalTitle:String)
    {
        // grab config share text from user defaults
        let prefs = NSUserDefaults.standardUserDefaults()
        let configText = prefs.objectForKey("shareText") as? String
        let shareText = configText! + goalTitle
        
        // present share view controller
        let avc = UIActivityViewController(activityItems:[shareText], applicationActivities: nil)
        vc.presentViewController(avc, animated: true, completion: nil)
    }
    
    func presentSettings(vc:UIViewController)
    {
        // create action sheet
        let actionSheet = UIAlertController(title: "Settings", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let emailSettings = UIAlertAction(title: "Email Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            // present emailSettingController
            let emailAlert = UIAlertController(title: "Change Email Settings", message: "We send you one weekly motivation email. Change your email address or delete it to stop receiving reminders.", preferredStyle: UIAlertControllerStyle.Alert)
            emailAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                if PFUser.currentUser()?.email != nil && PFUser.currentUser()?.email != "" {
                    textField.text = PFUser.currentUser()?.email
                }
                else {
                    textField.placeholder = "email"
                }
            })
            let change = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                PFUser.currentUser()?.setObject((emailAlert.textFields?.first?.text)!, forKey: "email")
                PFUser.currentUser()?.saveInBackground()
            })
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

            emailAlert.addAction(cancel)
            emailAlert.addAction(change)
            
            vc.presentViewController(emailAlert, animated: true, completion: nil)
            
        }
        
        let feedback = UIAlertAction(title: "Feedback", style: UIAlertActionStyle.Default) { (action) -> Void in
            let string = "mailto:getStrive@gmail.com?subject=Feedback%20On%20Strive";
            let url = NSURL(string: string)
            UIApplication.sharedApplication().openURL(url!)
        }

        let tos = UIAlertAction(title: "Terms of Service", style: UIAlertActionStyle.Default) { (action) -> Void in
            vc.performSegueWithIdentifier("tosSegue", sender: nil)
        }
        
        let ps = UIAlertAction(title: "Privacy Statement", style: UIAlertActionStyle.Default) { (action) -> Void in
            vc.performSegueWithIdentifier("psSegue", sender: nil)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(emailSettings)
        actionSheet.addAction(feedback)
        actionSheet.addAction(tos)
        actionSheet.addAction(ps)
        actionSheet.addAction(cancel)
        
        vc.presentViewController(actionSheet, animated: true, completion: nil)

    }
}
