//
//  TranslateViewController.swift
//  app
//
//  Created by Dongning Wang on 11/6/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit

class TranslateViewController: ChatView {
    
    var translatorView: TranslatorView!
    var transStatus = TRANS_STATUS_REQUESTED
    
    override init!(with groupId_: String!) {
        super.init(with: groupId_)
        self.tabBarItem.image = UIImage(named: "tab_groups.png")
        self.tabBarItem.selectedImage = UIImage(named: "tab_groups.png")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.image = UIImage(named: "tab_groups.png")
        self.tabBarItem.selectedImage = UIImage(named: "tab_groups.png")
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.hidesBottomBarWhenPushed) {
            self.inputToolbar?.hidden = true
        }
        if (self.transStatus == TRANS_STATUS_EXPIRED) {
            self.title = "Expired"
            self.inputToolbar?.hidden = true
            self.navigationController?.navigationBarHidden = false
        }
        else if (transStatus == TRANS_STATUS_ENDED) {
            self.title = "Session Ended"
            self.inputToolbar?.hidden = true
            self.translatorView.navigationController?.navigationBarHidden = false
        }
        
        // Do any additional setup after loading the view.
        //refresh badge
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
