//
//  LoginController+handlers.swift
//  GameOfChats
//
//  Created by Jackie on 10/24/18.
//  Copyright © 2018 LAS. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //authenticated user
            
            let imageName = NSUUID.init().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1)  {
                
            

//            if let uploadData = self.profileImageView.image!.pngData() {
                
                storageRef.put(uploadData, metadata: nil, completion: { (_, err) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]

                        self.registerUserIntoDatabasewithUID(uid: uid, values: values as [String : AnyObject])
                    })
                    
                })
            }
            
        })
    }
    
    private func registerUserIntoDatabasewithUID(uid: String, values: [String:AnyObject]) {
        
        
        let ref = FIRDatabase.database().reference( )
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
//            self.messagesController?.fetchUserAndSetupNavBarTitle()
//            self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User(dictionary: values)
            self.messagesController?.setupNavBarWithUser(user)
            
            self.dismiss(animated: true, completion: nil)
            print("Saved User into Database")
        })
        
    }
    
    @objc func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        // needed variable for swift 4.2.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
    
    
    
    
    
    
    
    
    
    
    
}
