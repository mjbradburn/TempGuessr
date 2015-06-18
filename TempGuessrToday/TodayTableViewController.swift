//
//  TodayTableViewController.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/17/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayTableViewController: UITableViewController, NCWidgetProviding {
    
    var preferredViewHeight : CGFloat {
        return 132
    }
    
    func updateSize() {
        var preferredSize = self.preferredContentSize
        preferredSize.height = self.preferredViewHeight
        self.preferredContentSize = preferredSize
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        Parse.setApplicationId("BbgNLdTyaFmYoQg4LtrYnryQxk1wfV6MP9629HMw",
            clientKey: "gMJIKpcckyYFkn60FC1neS10gngN1R64oQuP4MUO")
        
        tableView.backgroundColor = UIColor.clearColor()
        //updateSize()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        updateSize()
    }
    
    // MARK: - Widget Delegate Methods
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.tableView.reloadData()
        //tells extension to redraw itself
        completionHandler(NCUpdateResult.NewData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.textColor = UIColor.whiteColor()
        let findUsers : PFQuery = PFQuery(className: "_User")
        
        findUsers.findObjectsInBackgroundWithBlock({(objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                var userArray = [AnyObject]()
                
                for object in objects! {
                    let user : PFObject = object as! PFObject
                    userArray.append(user)
                }
                
                let user : PFObject = userArray[indexPath.row] as! PFObject
                let userName : String = user.objectForKey("username") as! String
                cell.textLabel!.text = "\(userName) just joined"
            }

        })
        
        
        
        return cell
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
