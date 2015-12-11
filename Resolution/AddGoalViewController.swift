//
//  AddGoalViewController.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit



class AddGoalViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var reminderSegmentControl:UISegmentedControl!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var editingHeaderView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var topdescriptionViewConstraint: NSLayoutConstraint!
    var defaultDescriptionString = String()
    var touchView = UITapGestureRecognizer()
    
    // optional items to be passed
    var agd:AddGoalDelegate?
    var editResolution:Resolution?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // housekeeping
        self.descriptionText.layer.cornerRadius = 5
        self.descriptionText.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.descriptionText.layer.borderWidth = 1
        self.descriptionText.delegate = self
        self.titleField.delegate = self
        
        
        // setup tap gesture recognizer
        self.touchView.addTarget(self, action:"dismissKeyboard")
        
        // check if editing or not
        if self.editResolution != nil {
            setupEditing()
        }
        else {
            self.defaultDescriptionString = self.descriptionText.text
        }
        if UIScreen.mainScreen().bounds.size.height > 480 {
            self.titleField.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressSave(sender: AnyObject) {
        if self.titleField.text != "" && self.descriptionText.text != "" && self.descriptionText.text != self.defaultDescriptionString  {
            var objectId:String?
            
            // call save function if we're creating a new resoultion
            if self.editResolution == nil {
                dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
                    objectId = ResolutionService().saveResolution(self.titleField.text!, comment: self.descriptionText.text, weeklyReminders: self.reminderSegmentControl.selectedSegmentIndex + 1)
                    dispatch_async(dispatch_get_main_queue()) {
                        // create resolution object
                        let newRes = Resolution()
                        newRes.title = self.titleField.text!
                        newRes.comment = self.descriptionText.text
                        newRes.weeklyUpdates = self.reminderSegmentControl.selectedSegmentIndex + 1
                        newRes.id = objectId
                    
                        // update
                        if self.agd != nil {
                            self.agd?.updatePage(newRes)
                        }
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
            
            // resolution exists and we want to update
            else
            {
                // update editResolution
                self.editResolution!.title = self.titleField.text!
                self.editResolution!.comment = self.descriptionText.text
                self.editResolution!.weeklyUpdates = self.reminderSegmentControl.selectedSegmentIndex + 1
                
                // background update resolution on the cloud
                dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
                    ResolutionService().updateResolution(self.editResolution!)
                }
                
                // update
                if self.agd != nil {
                    self.agd?.updatePage(self.editResolution!)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        else {
           HelperService().presentFailedSaveAlert(self)
        }
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            // no op
        }
    }
    
    /////////////////////
    //MARK:Text delegates
    /////////////////////
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // add gesture so we can dismiss keyboard for iphone 4 --> screen too small w/ keyboard
        if UIScreen.mainScreen().bounds.size.height <= 480 {
            self.view.addGestureRecognizer(self.touchView)
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if UIScreen.mainScreen().bounds.size.height <= 480 {
            self.titleField.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if self.descriptionText.text == "" {
            self.descriptionText.text = self.defaultDescriptionString
            self.descriptionText.textColor = UIColor.darkGrayColor()
        }
        
        // animate back down if iphone4
        if UIScreen.mainScreen().bounds.size.height <= 480 {
            self.topdescriptionViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if self.descriptionText.text == self.defaultDescriptionString {
            self.descriptionText.text = ""
            self.descriptionText.textColor = UIColor.blackColor()
        }
        
        // animate view up if iphone 4 --> so keyboard doesn't get in the way
        if UIScreen.mainScreen().bounds.size.height <= 480 {
            self.view.addGestureRecognizer(self.touchView)
            self.topdescriptionViewConstraint.constant = -1*self.editingHeaderView.frame.size.height
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func dismissKeyboard()
    {
        self.descriptionText.resignFirstResponder()
        self.titleField.resignFirstResponder()
    }
    
    //////////////////
    // MARK:Editing setup
    //////////////////
    func setupEditing() {
        self.titleField.text = self.editResolution?.title
        self.descriptionText.text = self.editResolution?.comment
        self.reminderSegmentControl.selectedSegmentIndex = (self.editResolution?.weeklyUpdates)!-1
        self.descriptionText.textColor = UIColor.blackColor()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
