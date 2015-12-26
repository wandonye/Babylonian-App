//
//  TranslateTabView.swift
//  app
//
//  Created by Dongning Wang on 11/14/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit
import Firebase

class TranslateTabView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var transButton: UIButton!
    @IBOutlet weak var statusSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var langPicker1: UIPickerView!
    
    @IBOutlet weak var langPicker2: UIPickerView!
    
    var transView: TransView!
    var candidateTranslator: PFUser!

    let pickerData = ["EN","CN","KR"]
    let app = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
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
        self.title = "Translate"
        langPicker1.dataSource = self
        langPicker1.delegate = self
        langPicker2.dataSource = self
        langPicker2.delegate = self
        self.statusSpinner.hidesWhenStopped = true
        langPicker1.selectRow(0, inComponent: 0, animated: true)
        langPicker1.selectRow(1, inComponent: 0, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil)
        {
            LoginUser(self)
        }
        else {
            self.transButton.enabled = true
            self.candidateTranslator = nil
        }
    }
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func startTransView(sender: AnyObject) {
        self.statusLabel.hidden = false
        self.statusSpinner.startAnimating()
        self.transButton.enabled = false

        requestTranslator()
    }
    
    func requestTranslator() {
        let query = PFQuery(className:PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_ROLE, equalTo: PF_USER_ROLE_TRANSLATOR)
        query.whereKey(PF_USER_AVAILABILITY, equalTo: PF_USER_AVAILABLE)
        query.addDescendingOrder(PF_USER_LASTACTIVE)
        query.addAscendingOrder(PF_USER_MISSEDREQUESTS)
        
        self.app.transStatus = APP_TRANS_STATUS_REQYESTED

        query.getFirstObjectInBackgroundWithBlock({
            (translator: PFObject?, error: NSError?) -> Void in
            if error == nil && translator != nil {
                
                self.candidateTranslator = translator as! PFUser
                let transId = StartNewTranslation(PFUser.currentUser(), translator as! PFUser)
                self.app.transStatus = APP_TRANS_STATUS_TRANSLATOR_FOUND
                self.statusSpinner.stopAnimating()
                
                self.transView = TransView.init(with: transId)
                self.transView.currentTranslator = self.candidateTranslator
                let date = NSDate()
                let formatter = NSDateFormatter()
                formatter.timeStyle = .MediumStyle
                
                self.transView.messageSend("Translation requested at "+formatter.stringFromDate(date), video: nil, picture: nil, audio: nil)
                self.notify(self.candidateTranslator.objectId!, msg: "Someone need your help")
 
                self.transView.hidesBottomBarWhenPushed = true
                self.transView.app_transStatus = APP_TRANS_STATUS_TRANSLATOR_FOUND
                self.navigationController?.pushViewController(self.transView, animated: true)
                
            } else {
                self.app.transStatus = APP_TRANS_STATUS_IDLE
                //print(error)
                ProgressHUD.showError("Oops! All translators are busy now.\n Try again in a few minutes.")
                self.statusSpinner.stopAnimating()
                self.statusLabel.hidden = true
                self.transButton.enabled = true
                
            }
        })
    }
    
    func notify(translatorId: String, msg: String) {
        let query = PFUser.query()
        query!.whereKey(PF_USER_OBJECTID, equalTo: translatorId)
        query?.limit = 100
        let queryInstallation = PFInstallation.query()
        queryInstallation?.whereKey(PF_INSTALLATION_USER, matchesQuery: query!)
        
        let push = PFPush()
        push.setQuery(queryInstallation)
        push.setData(["alert":msg, "sound":"default", "category":"ACTIONABLE", "badge":"Increment"])
        push.sendPushInBackground()
    }
    
}
