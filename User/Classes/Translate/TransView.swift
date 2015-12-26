//
//  TransView.swift
//  app
//
//  Created by Dongning Wang on 11/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import UIKit

class TransView: ChatView, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder!
    var filePathStr: String!
    let voiceButton = UIButton()
    let cameraButton = UIButton()
    let pictureButton = UIButton()
    let textButton = UIButton()
    let closeButton = UIButton()
    let topTapbar = TopTabBar()
    var currentTranslator: PFUser!
    var timer = NSTimer()
    var loopCounter = 0
    var app_transStatus = APP_TRANS_STATUS_LIMBO
    
    override init!(with groupId_: String!) {
        super.init(with: groupId_)
        self.tabBarItem.image = UIImage(named: "tab_groups.png")
        self.tabBarItem.selectedImage = UIImage(named: "tab_groups.png")
        //self.transId = groupId_
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
        
        self.inputToolbar?.hidden = true
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
        let viewXmax = UIScreen.mainScreen().bounds.width
        let buttonWidth = (viewXmax-110)/4

        voiceButton.setTitle("Press and Hold", forState: .Normal)
        voiceButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        voiceButton.frame = CGRectMake(0, 0, 100, 100)
        voiceButton.setImage(UIImage(named: "mic_normal.png") as UIImage?, forState: .Normal)
        voiceButton.addTarget(self, action: "startRecord:", forControlEvents: .TouchDown)
        voiceButton.addTarget(self, action: "stopRecord:", forControlEvents: .TouchUpInside)
        voiceButton.addTarget(self, action: "cancelRecord:", forControlEvents: .TouchUpOutside)
        
        topTapbar.frame = CGRectMake(0, 0, viewXmax, 48)
        self.view.addSubview(topTapbar)
        var center = self.topTapbar.center
        center.y = center.y + 26
        voiceButton.center = center
        self.view.addSubview(voiceButton)

        
        cameraButton.setTitle("Camera", forState: .Normal)
        //cameraButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        cameraButton.tintColor = UIColor.blackColor()
        cameraButton.frame = CGRectMake(0, 0, buttonWidth, 32)
        center.y = center.y - 6
        center.x = viewXmax -  buttonWidth/2
        cameraButton.center = center
        cameraButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cameraButton.setImage(UIImage(named: "camera_gray.png") as UIImage?, forState: .Normal)
        cameraButton.addTarget(self, action: "startCamera:", forControlEvents: .TouchDown)
        self.view.addSubview(cameraButton)
        
        pictureButton.setTitle("Picture", forState: .Normal)
        //pictureButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        pictureButton.frame = CGRectMake(0, 0, buttonWidth, 32)
        center.x = center.x - buttonWidth
        pictureButton.center = center
        pictureButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        pictureButton.setImage(UIImage(named: "pictures_gray.png") as UIImage?, forState: .Normal)
        pictureButton.addTarget(self, action: "addPicture:", forControlEvents: .TouchDown)
        self.view.addSubview(pictureButton)

        textButton.setTitle("Text", forState: .Normal)
        //textButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        textButton.frame = CGRectMake(0, 0, buttonWidth, 32)
        center.x = buttonWidth*3/2
        textButton.center = center
        textButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        textButton.setImage(UIImage(named: "text_gray.png") as UIImage?, forState: .Normal)
        textButton.addTarget(self, action: "textMessage:", forControlEvents: .TouchDown)
        self.view.addSubview(textButton)
        
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.frame = CGRectMake(0, 0, buttonWidth, 32)
        center.x = buttonWidth/2
        closeButton.center = center
        closeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        closeButton.setImage(UIImage(named: "back.png") as UIImage?, forState: .Normal)
        closeButton.addTarget(self, action: "backToAll:", forControlEvents: .TouchDown)
        self.view.addSubview(closeButton)
        
        //refresh badge
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil)
        {
            ParentLoginUser(self)
        }
        if (self.senderId == nil){
            self.senderId = PFUser.currentId()
            self.senderDisplayName = PFUser.currentName()
        }
        if (self.app_transStatus == APP_TRANS_STATUS_TRANSLATOR_FOUND){
            self.timer = NSTimer.scheduledTimerWithTimeInterval(50, target: self, selector: "update", userInfo: nil, repeats: true)
            self.freezeButtons()
        }
        super.viewWillAppear(animated)
    }
    
    func textMessage(sender:UIButton!) {
        if self.inputToolbar?.hidden == true {
            self.inputToolbar?.hidden = false
            self.inputToolbar?.contentView?.textView?.becomeFirstResponder()
        }
        else {
            self.inputToolbar?.contentView?.textView?.resignFirstResponder()
            self.inputToolbar?.hidden = true
        }
    }
    
    func terminateTranslate() {
        //release translator
        PFCloud.callFunctionInBackground("updateFinishedTranslatorStatus", withParameters: ["userId": self.currentTranslator.objectId!], block: {
            (result, error) in
            if (error != nil) {
                print(error)
            }
        })

        //TODO Use transId as index to remove this part
        let ref = Firebase(url: FIREBASE+"/Trans/")
        let query = ref.queryOrderedByChild("transId").queryEqualToValue(self.transId)
        //let query0 = ref.queryEqualToValue(self.transId, childKey: "transId")
        
        query.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)
            if (!(snapshot.value is NSNull)) {
                for val in snapshot.value.allValues {
                    let session = val as! NSDictionary
                    let updateref = Firebase(url: FIREBASE+"/Trans/" + (session["refkey"] as! String))
                    updateref.updateChildValues([TRANS_STATUS:TRANS_STATUS_ENDED])
                }
            }

            }, withCancelBlock: { error in
                print(error.description)
        })
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        self.messageSend("Translation ended at "+formatter.stringFromDate(date), video: nil, picture: nil, audio: nil)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func backToAll(sender:UIButton!) {
        let endTransAlert = UIAlertController(title: "End Translation", message: "This will end the translation session. Confirm?", preferredStyle: UIAlertControllerStyle.Alert)
        
        endTransAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.terminateTranslate()
        }))
        
        endTransAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            //println("Handle Cancel Logic here")
        }))
        
        presentViewController(endTransAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRecord(sender:UIButton!) {
        let image = UIImage(named: "mic_talk.png") as UIImage?
        voiceButton.setImage(image, forState: .Normal)
        //Unique recording URL
        let fileName = NSProcessInfo.processInfo().globallyUniqueString + ".m4a"
        self.filePathStr = NSTemporaryDirectory() + fileName
        self.record()
    }
    func stopRecord(sender:UIButton!) {
        let image = UIImage(named: "mic_normal.png") as UIImage?
        voiceButton.setImage(image, forState: .Normal)
        //TODO check self.recordingFilePath, caution about touch down outside and up inside
        self.audioRecorder.stop()
        self.messageSend(nil, video:nil, picture:nil, audio:"\(self.filePathStr)")
        self.collectionView?.reloadData()
    }
    func cancelRecord(sender:UIButton!) {
        let image = UIImage(named: "mic_normal.png") as UIImage?
        voiceButton.setImage(image, forState: .Normal)
    }
    func addPicture(sender:UIButton!) {
        PresentPhotoLibrary(self, true)
    }
    
    func startCamera(sender:UIButton!) {
        PresentMultiCamera(self, true)
    }
    
    func record() {
        //init
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    //print("granted")
                    
                    //set category and activate recorder session
                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! audioSession.setActive(true)
                    
                    //create AnyObject of settings

                    let settings: [String : AnyObject] = [
                        AVFormatIDKey:Int(kAudioFormatMPEG4AAC), //Int required in Swift2
                        AVSampleRateKey:44100.0,
                        AVNumberOfChannelsKey:2
                    ]
                    
                     //record
                    if let url = NSURL(string: self.filePathStr) {
                        self.audioRecorder = try? AVAudioRecorder(URL: url, settings: settings)
                        self.audioRecorder.delegate = self
                        self.audioRecorder.meteringEnabled = true
                        self.audioRecorder.prepareToRecord()
                        self.audioRecorder.record()
                    }
                    else {
                        print("error")
                    }
                    
                } else{
                    print("not granted")
                    return 
                }
            })
        }
        
    }

    override func addMessage(item: [NSObject : AnyObject]!) -> Bool {
        let result = super.addMessage(item)
        if (self.app_transStatus != APP_TRANS_STATUS_ONGOING) {
            NSLog((item["userId"] as? String)! + " ?==? " + self.currentTranslator.objectId!)
            if (item["userId"] as? String == self.currentTranslator.objectId) {
                self.app_transStatus = APP_TRANS_STATUS_ONGOING
                self.connectedToTranslator()
            }
        }
        return result
    }

    override func loadMessageNonInit(item: [NSObject : AnyObject]!) {
        if (self.app_transStatus != APP_TRANS_STATUS_ONGOING) {
            NSLog((item["userId"] as? String)! + " ?=? " + self.currentTranslator.objectId!)
            if (item["userId"] as? String == self.currentTranslator.objectId) {
                self.app_transStatus = APP_TRANS_STATUS_ONGOING
                self.connectedToTranslator()
            }
        }
        super.loadMessageNonInit(item)
    }
/*
    override func finishReceivingMessage() {
        if (self.app_transStatus != APP_TRANS_STATUS_ONGOING) {
            //NSLog((self.messages.lastObject?.senderId())!)
            //NSLog(self.currentTranslator.objectId!)
            for message in self.messages {
                if (message.senderId() == self.currentTranslator.objectId) {
                    self.app_transStatus = APP_TRANS_STATUS_ONGOING
                    self.connectedToTranslator()
                }
            }
 
        }
        super.finishReceivingMessage()
    }
*/
/*    func update(){
        self.messages.removeAllObjects()
        
        self.loopCounter++
        
        if (self.app_transStatus == APP_TRANS_STATUS_ONGOING) {
            self.connectedToTranslator()
            
            self.delayedReload()
        }
        else if (self.app_transStatus == APP_TRANS_STATUS_IDLE) {
            //got no one available
            self.loopCounter = 0
            self.timer.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "update", userInfo: nil, repeats: true)
            requestTranslator()
        }
        
        self.firebase1.observeEventType(.ChildAdded, withBlock: {snapshot in
            self.addMessage(snapshot.value as! [NSObject : AnyObject])
            for message in self.messages {
                NSLog((message as! JSQMessage).senderId)
                NSLog(self.currentTranslator.objectId!)
                
                if ((message as! JSQMessage).senderId == self.currentTranslator.objectId) {
                    self.app_transStatus = APP_TRANS_STATUS_ONGOING
                    self.connectedToTranslator()
                    
                }
            }
            //self.finishReceivingMessage()
        })
        
        if (self.loopCounter>10) {
            self.loopCounter = 0
            
            //this guy is invalid, missed one request
            
            if (self.currentTranslator != nil) {
                self.translatorDidnotResponse(self.currentTranslator)
            }
            
        }
    }
    */
    func connectedToTranslator() {
        print("connected")
        self.timer.invalidate()
        ProgressHUD.showSuccess("Connected")
        self.unfreezeButtons()
        self.loopCounter = 0
        
        PFCloud.callFunctionInBackground("updateAcceptedTranslatorStatus", withParameters: ["userId": self.currentTranslator.objectId!], block: {
            (result, error) in
            if (error != nil) {
                print(error)
            }
        })
    }
    
    func update() {
        print("called update")
        if (self.app_transStatus != APP_TRANS_STATUS_ONGOING){
            if (self.app_transStatus != APP_TRANS_STATUS_IDLE){
                self.translatorDidnotResponse(self.currentTranslator)
            }
            else {
                self.requestTranslator()
            }
        }
        
    }
    
    func requestTranslator() {
        //sleep(3)
        
        let query = PFQuery(className:PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_ROLE, equalTo: PF_USER_ROLE_TRANSLATOR)
        query.whereKey(PF_USER_AVAILABILITY, equalTo: PF_USER_AVAILABLE)
        query.addAscendingOrder(PF_USER_MISSEDREQUESTS)
        query.addDescendingOrder(PF_USER_LASTACTIVE)
        
        query.getFirstObjectInBackgroundWithBlock({
            (translator: PFObject?, error: NSError?) -> Void in
            if error == nil && translator != nil {
                
                self.currentTranslator = translator as! PFUser
                let transId = StartNewTranslation(PFUser.currentUser(), translator as! PFUser)
                self.app_transStatus = APP_TRANS_STATUS_REQYESTED
                
                self.transId = transId
                
                self.firebase1 = Firebase(url: FIREBASE+"/Message/"+self.transId);
                self.messages.removeAllObjects()
                self.loadMessages()
                //self.delayedReload()
                
                
                let date = NSDate()
                let formatter = NSDateFormatter()
                formatter.timeStyle = .MediumStyle
                self.messageSend("Translation requested at "+formatter.stringFromDate(date), video: nil, picture: nil, audio: nil)
                
                self.notify(self.currentTranslator.objectId!, msg: "Someone need your help")
                
            } else {
                //self.app_transStatus = APP_TRANS_STATUS_IDLE
                //print(error)
                //self.timer.invalidate()
                //ProgressHUD.showError("Oops! All translators are busy now.\n Try again in a few minutes.")
                //self.terminateTranslate()
            }
        })

    }
    
    func translatorDidnotResponse(translator : PFUser) {
        //TODO make that chat status into expired
        NSLog(translator.username!)
        let ref = Firebase(url: FIREBASE+"/Trans/")
        let query = ref.queryOrderedByChild("transId").queryEqualToValue(self.transId)
        //let query0 = ref.queryEqualToValue(self.transId, childKey: "transId")
        
        query.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value.allValues)
            if (!(snapshot.value is NSNull)) {
                for val in snapshot.value.allValues {
                    let session = val as! NSDictionary
                    let updateref = Firebase(url: FIREBASE+"/Trans/" + (session["refkey"] as! String))
                    updateref.updateChildValues([TRANS_STATUS:TRANS_STATUS_EXPIRED])
                }
            }
            else {
                print(self.transId)
            }

            }, withCancelBlock: { error in
                print(error.description)
        })
        
        PFCloud.callFunctionInBackground("updateNonrespondingTranslatorStatus", withParameters: ["userId": translator.objectId!], block: {
            (result, error) in
            self.requestTranslator()
            if (error != nil) {
                print(error)
            }
        })
    }

    func freezeButtons(){
        voiceButton.enabled = false
        cameraButton.enabled = false
        pictureButton.enabled = false
        textButton.enabled = false
    }
    func unfreezeButtons(){
        voiceButton.enabled = true
        cameraButton.enabled = true
        pictureButton.enabled = true
        textButton.enabled = true
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
