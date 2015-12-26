//
//  LeaderBoardView.swift
//  app
//
//  Created by Dongning Wang on 12/1/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit

class LeaderBoardView: UITableViewController {
    var topUsers : [PFObject]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.image = UIImage(named: "tab_leaderboard.png")
        loadusers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.title = "LeaderBoard"
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "topUsers")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadusers() {
        if (PFUser.currentUser()==nil) {
            return
        }
        let userquery = PFQuery(className: PF_USER_CLASS_NAME)
        userquery.limit = 10
        userquery.selectKeys([PF_USER_FULLNAME,PF_USER_TRANSLATENUM,PF_USER_THUMBNAIL])
        userquery.addDescendingOrder(PF_USER_TRANSLATENUM)
        userquery.findObjectsInBackgroundWithBlock({
            (objects:[PFObject]?, error:NSError?) -> Void in

            self.topUsers = objects as [PFObject]!
        })

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("topUsers", forIndexPath: indexPath)
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "topUsers")

        // Configure the cell...
        if (self.topUsers != nil && indexPath.row<self.topUsers?.count) {
            cell.textLabel?.text = (self.topUsers as! [PFUser])[indexPath.row][PF_USER_FULLNAME] as? String
            cell.detailTextLabel?.text = "has finished "+String((self.topUsers as! [PFUser])[indexPath.row][PF_USER_TRANSLATENUM])+" translation"
        }
        return cell
    }


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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
