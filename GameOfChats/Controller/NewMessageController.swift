//
//  NewMessageController.swift
//  GameOfChats
//
//  Created by Jackie on 10/24/18.
//  Copyright © 2018 LAS. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
      
    
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key 
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                //                user.name = dictionary["name"]
            }
            
        }, withCancel: nil)
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            
            
    }
        return cell
        
}
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
        print("dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user) 
        }
    }

}


