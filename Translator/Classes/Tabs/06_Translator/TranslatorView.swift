//
//  TranslatorView.swift
//  app
//
//  Created by Dongning Wang on 11/15/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit

class TranslatorView: RecentView {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.image = UIImage(named: "tab_groups.png")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Translate"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        
        let user = PFUser.currentUser()
        if (user != nil) {
            user![PF_USER_LASTACTIVE] = NSDate()
            user![PF_USER_AVAILABILITY] = PF_USER_AVAILABLE
            user?.saveInBackground()
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Translation"
    }
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .Center
        }
    }
    
    override func actionChat(groupId: String!) {
        
        let translatorChat = TransView(with: groupId)
        translatorChat.hidesBottomBarWhenPushed = true
        translatorChat.translatorView = self
        self.navigationController?.pushViewController(translatorChat, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let recent = self.recents[indexPath.row] as! NSDictionary
        let date = String2Date(recent["date"] as! String)
        let seconds = -date.timeIntervalSinceNow
        //print(seconds)
        
        if ((recent[TRANS_STATUS] as! String) == TRANS_STATUS_ENDED){
            let translateView = TranslateViewController.init(with: recent["transId"] as! String)
            translateView.transStatus = TRANS_STATUS_ENDED
            translateView.translatorView = self
            self.navigationController?.pushViewController(translateView, animated: true)
        }
        else if (seconds>4000){
            recent.setValue(TRANS_STATUS_EXPIRED, forKey: TRANS_STATUS)
            let ref = Firebase(url: FIREBASE+"/Trans/"+(recent["refkey"] as! String))
            ref.updateChildValues([TRANS_STATUS:TRANS_STATUS_EXPIRED])
            //something unexpected, such translation should have ended, update the record
        }
        
        if ((recent[TRANS_STATUS] as! String) == TRANS_STATUS_EXPIRED) {
            ProgressHUD.showError("The request is expired")
            let translateView = TranslateViewController.init(with: recent["transId"] as! String)
            translateView.transStatus = TRANS_STATUS_EXPIRED
            translateView.translatorView = self
            self.navigationController?.pushViewController(translateView, animated: true)
        }
        else if ((recent[TRANS_STATUS] as! String) == TRANS_STATUS_REQUESTED){
            let user = PFUser.currentUser()
            
            user?[PF_USER_AVAILABILITY] = PF_USER_BUSY
            user?[PF_USER_TRANSLATENUM] = (user?[PF_USER_TRANSLATENUM] as! Int) + 1
            user?.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if (error != nil)
                {
                    //[self loginFailed:@"Failed to save user data."];
                }
            }
            
            let ref = Firebase(url: FIREBASE+"/Trans/"+(recent["refkey"] as! String))
            ref.updateChildValues([TRANS_STATUS:TRANS_STATUS_ACCEPTED])
            
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.timeStyle = .MediumStyle
            
            let translatorChat = TransView(with: recent["transId"] as! String)
            translatorChat.messageSend("Started at"+formatter.stringFromDate(date), video: nil, picture: nil, audio: nil)
            
            translatorChat.hidesBottomBarWhenPushed = true
            translatorChat.translatorView = self
            self.navigationController?.pushViewController(translatorChat, animated: true)
        }
        else if ((recent[TRANS_STATUS] as! String) == TRANS_STATUS_ACCEPTED){
            let translatorChat = TransView(with: recent["transId"] as! String)

            translatorChat.hidesBottomBarWhenPushed = true
            translatorChat.translatorView = self
            self.navigationController?.pushViewController(translatorChat, animated: true)
            
        }

    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
