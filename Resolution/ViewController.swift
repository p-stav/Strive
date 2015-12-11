//
//  ViewController.swift
//  Resolution
//
//  Created by Paul Stavropoulos on 12/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

import UIKit
import Parse
import ParseUI


class ViewController: UIViewController,PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,AddGoalDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var quoteTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noGoalTextView: UITextView!
    var resolutions:NSMutableArray = []

    
    // unwinding from tutorial
    @IBAction func unwindToViewController(segue:UIStoryboardSegue) {
        grabResolutions()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // make title "" so that it doesn't show in navigation view
        self.title = ""
        
        if segue.identifier == "addNewGoalSegue" {
            let agvc = segue.destinationViewController as? AddGoalViewController
            agvc?.agd = self
        }
        
        if segue.identifier == "goalDetailPageSegue" {
            let gdvc = segue.destinationViewController as? GoalDetailViewController
            gdvc?.resolution = sender as? Resolution
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageSetup()
        
        // grab current resolutions
        setQuote()
        grabResolutions()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // make title "" so that it doesn't show in navigation view
        self.title = "Strive"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if there is a user
        checkCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////
    // MARK: setup and refresh code
    ///////////////////////
    func grabResolutions() {
        dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            self.resolutions = ResolutionService().getActiveResolutions()
            dispatch_async(dispatch_get_main_queue()) {
                // reload table
                
                if self.resolutions.count == 0 {
                    self.noGoalTextView.hidden = false
                }
                else {
                    self.noGoalTextView.hidden = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func setQuote() {
        // grab quote
        dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            let quote:String = ResolutionService().getQuote()
            
            dispatch_async(dispatch_get_main_queue()) {
        
                // set quote and attributes
                self.quoteTextView.text = quote
                self.quoteTextView.textColor = UIColor(colorLiteralRed: 82.0/255, green: 75.0/255, blue: 233.0/255, alpha: 1.0)
                self.quoteTextView.font = UIFont(name:"TrebuchetMS-Italic", size: 25.0)

                
                // height work
                let fixedWidth = UIScreen.mainScreen().bounds.size.width - 16
                self.quoteTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                let newSize = self.quoteTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
                var newFrame = self.quoteTextView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                self.quoteTextView.frame = newFrame;
                
                self.quoteTextViewHeightConstraint.constant = newFrame.size.height
                
                // check if tableHeader is too small
                if self.tableHeader.frame.size.height - 20 < self.quoteTextViewHeightConstraint.constant
                {
                    self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, self.quoteTextViewHeightConstraint.constant + 20)
                }
                
                self.tableView.tableHeaderView = self.tableHeader
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    ///////////////////////
    // MARK:table properties
    ///////////////////////
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resolutions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // set cell and get Resolution
        let cell = tableView.dequeueReusableCellWithIdentifier("ResolutionsCell", forIndexPath: indexPath) as! ResolutionTableViewCell
        let resolution:Resolution = self.resolutions.objectAtIndex(indexPath.row) as! Resolution
        
        cell.headerLabel.text = resolution.title
        
        if resolution.weeklyUpdates == 1 {cell.secondaryInfo.text = "\(resolution.weeklyUpdates) weekly alert"}
        else {cell.secondaryInfo.text = "\(resolution.weeklyUpdates) weekly alerts"}
    
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // segue to detailview
        self.performSegueWithIdentifier("goalDetailPageSegue", sender:self.resolutions.objectAtIndex(indexPath.row))
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    ///////////////////////
    // MARK:login/signup functionality
    ///////////////////////
    func checkCurrentUser() {
        if PFUser.currentUser() == nil {
            self.performSegueWithIdentifier("appFirstRunSegue", sender: nil)
        }
    }
    
    ///////////////
    // MARK:updating views
    ///////////////
    func updatePage(resolution: Resolution) {
        // add resolution
        self.resolutions.addObject(resolution)
        self.noGoalTextView.hidden = true
        self.tableView.reloadData()
    }
    
    func removeResolution(notification:NSNotification) {
        // get objectId
        let objectId:String = notification.object as! String
        
        // find object with matching 
        let position:Int = self.resolutions.indexOfObjectPassingTest { (dict, int, bool) in
            return (dict as!Resolution).id == objectId
        }
        
        if position != NSNotFound {
            // remove this
            self.resolutions.removeObjectAtIndex(position)
            self.tableView.reloadData()
        }
    }
    
    
    ///////////////
    // Page setup
    ///////////////
    func pageSetup() {
        // register uitableviewcell and housekeeping
        self.tableView.registerNib(UINib(nibName: "ResolutionCell", bundle: nil), forCellReuseIdentifier: "ResolutionsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clearColor()
        
        // register notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"removeResolution:", name:"removeResolution", object: nil)
        
        // grab share text from parse Config File
        ResolutionService().getShareConfigText()
        
        // set uibarbutton 
        let settingsButton = UIButton(frame: CGRectMake(0,0,30,30))
        settingsButton.setImage(UIImage(named: "settingGear.png"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action:"didPressSettings", forControlEvents: UIControlEvents.TouchUpInside)
        
        let barBtnItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.rightBarButtonItem = barBtnItem
    }
    
    func didPressSettings()
    {
        HelperService().presentSettings(self)
    }
}

