//
//  LoginSignupPresenter.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LoginSignupPresenter: NSObject,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    func presentLoginSignup() {
        // show sign in page
        let logInController = PFLogInViewController()
        let signInController = PFSignUpViewController()
        
        logInController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .Facebook]
        logInController.facebookPermissions = ["email"]
        logInController.signUpController = signInController
        logInController.delegate = self
        
        // some more customization
        logInController.logInView?.logo = UIImageView(image: UIImage(named:"add_button.png"))
        
        //present
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(logInController, animated:true, completion: nil)
    }
    
    // MARK:login/signup methods
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        
        // if signed up with facebook, grab email
        //TODO: grab FB email, create FB app
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(controller: PFLogInViewController) -> Void {
       controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) -> Void {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
