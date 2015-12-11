//
//  FirstRunViewController.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/9/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//
import Parse
import ParseUI
import UIKit
import ParseFacebookUtilsV4

class FirstRunViewController: UIViewController,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///////////////////////
    // MARK:login/signup functionality
    ///////////////////////
    @IBAction func didPressContinue(sender: AnyObject) {
        if PFUser.currentUser() == nil {
            // setup and show sign in page
            let logInController = PFLogInViewController()
            let signInController = PFSignUpViewController()
            logInController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .Facebook]
            logInController.facebookPermissions = ["email"]
            logInController.delegate = self
            signInController.delegate = self
            logInController.signUpController = signInController
            logInController.signUpController?.delegate = self
            
            // some more customization
            logInController.logInView?.logo = UIImageView(image: UIImage(named:"strive_signin.png"))
            signInController.signUpView?.logo = UIImageView(image: UIImage(named:"strive_signin.png"))
            
            //present
            self.presentViewController(logInController, animated:true, completion: nil)
        }
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        // add installation
        let installation = PFInstallation.currentInstallation()
        installation.setObject(PFUser.currentUser()!, forKey: "user")
        installation.saveInBackground()
        
        // if signed up with facebook, grab email
        if PFFacebookUtils.isLinkedWithUser(user) {
            ResolutionService().getEmailFromFacebook(self)
        }
        else {
            // set email settings to yes
            PFUser.currentUser()?.setValue(true, forKey: "emailSettings")
            PFUser.currentUser()?.saveInBackground()
        }
        
        // register for push notifications
        registerforPushNotifications()
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("unwindToViewControllerSegue", sender: nil)
    }
    
    
    func logInViewControllerDidCancelLogIn(controller: PFLogInViewController) -> Void {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        // add installation
        let installation = PFInstallation.currentInstallation()
        installation.setObject(PFUser.currentUser()!, forKey: "user")
        installation.saveInBackground()
        
        // register for push notifications
        registerforPushNotifications()
        
        self.performSegueWithIdentifier("unwindToViewControllerSegue", sender: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print(error)
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) -> Void {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func registerforPushNotifications () {
        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
}
