//
//  ViewController.swift
//  GameOfChats
//
//  Created by Jackie on 10/22/18.
//  Copyright © 2018 LAS. All rights reserved.
//

import UIKit
import Firebase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class MessagesController: UITableViewController {
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
                checkIfUserIsLoggedIn()
        
        let image = UIImage(named:"new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
//        observeMessages()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    
    func observeUserMessgages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

//                print(snapshot)
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp?.intValue > message2.timestamp?.intValue
                        })
                        
                        self.timer?.invalidate()
                        print("we just canceled our timer")
                        
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        print("schedule a table reload in 0.1 sec")
                    }
                    
                    
                    //this will crash because of background thread, so lets call this on dispatch_async main thread
//                    DispatchQueue.main.async(execute: {
//                        self.tableView.reloadData()
//                    })
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }
    
//    func observeMessages() {
//        let ref = FIRDatabase.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message()
//                message.setValuesForKeys(dictionary)
////                self.messages.append(message)
//
//                if let toId = message.toId {
//                self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort(by: { (message1, message2) -> Bool in
//                        return message1.timestamp?.intValue > message2.timestamp?.intValue
//                    })
//
//                    
//                }
//
//
//                //this will crash because of background thread, so lets call this on dispatch_async main thread
//                DispatchQueue.main.async(execute: {
//                    self.tableView.reloadData()
//                })
//            }
//
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }

        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
        
    }
    
    
//YOUTUBE NAV BAR - works but not centered
    
    func setupNavBarWithUser(_ user : User){
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessgages()
        // self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = UIColor.black


 

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profilerUmageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profilerUmageUrl)
        }

        containerView.addSubview(profileImageView)

        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
//
        //Doesn't work
        //profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //nedd x,y,widhtmheight anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo : profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView
    }

    
    
    
    
   //ORIGNAL NAV BAR - doesn't work but centered
    
    
//    func setupNavBarWithUser(_ user: User) {
//
//        let titleView = UIView()
//
//        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
////        titleView.backgroundColor = UIColor.red
//
//        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
//        zoomTap.numberOfTapsRequired = 1
//        titleView.addGestureRecognizer(zoomTap)
//        titleView.isUserInteractionEnabled = true
//
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        titleView.addSubview(containerView)
//
//        let profileImageView = UIImageView()
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = 20
//        profileImageView.clipsToBounds = true
//        if let profileImageUrl = user.profileImageUrl {
//            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
//
//        containerView.addSubview(profileImageView)
////
//        //ios 9 constraint anchors
//        //need x,y,width,height anchors
//        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
//        profileImageView.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
//
//
//        let nameLabel = UILabel()
//
//        containerView.addSubview(nameLabel)
//        nameLabel.text = user.name
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        //need x,y,width,height anchors
//        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
//        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
//
//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//
//        self.navigationItem.titleView = titleView
////        let button = UIButton(type: .system)
////        button.setTitle(user.name, for: .normal)
////        button.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
////        self.navigationItem.titleView = button
////        button.setTitleColor(.darkGray, for: .normal)
//
//    }
    
    
    @objc func showChatControllerForUser(user:User) {

        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        chatLogController.user = user

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
           
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)

    }
    
    
    
    
    @objc func handleNewMessage () {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
        
        
        
    }
    
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else { fetchUserAndSetupNavBarTitle()
            
            
//            let uid = FIRAuth.auth()?.currentUser?.uid
//            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//
//                if let dictionary = snapshot.value as? [String: AnyObject] {
//                    self.navigationItem.title = dictionary["name"] as? String
//                }
//
//            }, withCancel: nil)
        }
    }
    
    
    
    
    @objc func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated:  true, completion: nil )
        }
    
    
    


}

