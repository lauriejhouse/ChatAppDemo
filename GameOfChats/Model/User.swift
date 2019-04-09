//
//  User.swift
//  GameOfChats
//
//  Created by Jackie on 10/24/18.
//  Copyright © 2018 LAS. All rights reserved.
//

import UIKit


class User: NSObject {
    @objc var id: String?
    @objc var name: String?
   @objc var email: String?
    @objc var profileImageUrl: String?
    
    init(dictionary: [AnyHashable: Any]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}


//https://www.letsbuildthatapp.com/course_video?id=59
