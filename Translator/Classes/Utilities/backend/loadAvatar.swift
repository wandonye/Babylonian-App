//
//  loadAvatar.swift
//  Babylonian
//
//  Created by Dongning Wang on 12/5/15.
//  Copyright © 2015 KZ. All rights reserved.
//

import Foundation


func downloadThumbnails(users: [PFUser]) -> [String:UIImage]? {
    var avatars: [String:UIImage]
    for user in users {
        AFDownload.start(user[PF_USER_THUMBNAIL] as! String, complete: {(path: String!, error: NSError!, network: Bool) in
            if error == nil {
                avatars[user.objectId!] = UIImage(contentsOfFile: path)!
            }
            else {
                avatars[user.objectId!] = UIImage(named: "settings_blank")!
            }
        })
    }
    return avatars
}