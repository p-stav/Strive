//
//  GoalDetailViewController.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit

class GoalDetailViewController: UIViewController, AddGoalDelegate {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weeklyReminderLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var resolution:Resolution?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editResolutionSegue" {
            let agvc = segue.destinationViewController as? AddGoalViewController
            agvc?.agd = self
            agvc?.editResolution = sender as? Resolution
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////
    // MARK:action items
    //////////////////
    @IBAction func didPressShareIcon(sender: AnyObject) {
        // pop up share sheet from helperservice
        HelperService().presentShareDialog(self, goalTitle:self.resolution!.title)
    }
    @IBAction func didPressEditIcon(sender: AnyObject) {
        // edit
        self.performSegueWithIdentifier("editResolutionSegue", sender:self.resolution)
    }
    @IBAction func didPressDeleteButton(sender: AnyObject) {
        // call delete method from share service
        HelperService().presentDeleteResolution((self.resolution?.id)!, vc: self)
    }
    
    //////////////////
    // MARK:page setup
    //////////////////
    func pageSetup() {
        if self.resolution != nil {
            // setup page
            self.titleTextView.text = self.resolution?.title
            self.descriptionTextView.text = self.resolution?.comment
            if self.resolution!.weeklyUpdates == 1 {self.weeklyReminderLabel.text = "\(self.resolution!.weeklyUpdates) weekly alert"}
            else {self.weeklyReminderLabel.text = "\(self.resolution!.weeklyUpdates) weekly alerts"}
        }
        
        // style
        self.titleTextView.font = UIFont.systemFontOfSize(24)
        self.titleTextView.textColor = UIColor.whiteColor()
        self.titleTextView.textAlignment = NSTextAlignment.Center
        
        // check constraints
        let fixedWidth = UIScreen.mainScreen().bounds.size.width - 16
        self.titleTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = self.titleTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = self.titleTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        if newFrame.height > self.titleTextView.frame.size.height {
            self.titleTextViewHeightConstraint.constant = newFrame.height
            self.headerViewHeightConstraint.constant = newFrame.height + self.weeklyReminderLabel.frame.size.height + 50
        }
    }
    
    //////////////////
    // MARK:Add Goal Delegate
    //////////////////
    func updatePage(resolution: Resolution) {
        pageSetup()
    }

}
