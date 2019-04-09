//
//  Message.swift
//  GameOfChats
//
//  Created by Jackie Norstrom on 10/31/18.
//  Copyright © 2018 LAS. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    @objc var fromId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    @objc var toId: String?
    
    func chatPartnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
        
        
    }
}
