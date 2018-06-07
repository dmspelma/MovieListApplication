//
//  ProfileController.swift
//  MovieList
//
//  Created by Drew Spelman on 4/10/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //var ViewController: UIViewController?
    let viewController = ViewController()
    var email: String?
    var profileurl: String?
    var username: String?
    var fullname: String?
    var location: String?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    var fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let fullnameSeparatorView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "User Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let usernameSeparatorView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Location"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let locationSeparatorView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.backgroundColor = UIColor.lightGray
        
        // Tapping Action!!!
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        // show Image Picker!!!! (Modally)
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
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
    
    @objc func handleUpdate() {

        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //successfully authenticated user

        // upload profile image
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

        // Compress Image into JPEG type
        if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {

            _ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error when uploading profile image")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.profileurl = metadata.downloadURL()?.absoluteString
                self.registerUserIntoDatabaseWithUID(uid)
            }
        }
    }

    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)

        let values = ["email": email, "fullname": fullnameTextField.text, "username": usernameTextField.text,"location": locationTextField.text, "profileurl": profileurl] as [String : AnyObject]

        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in

            if err != nil {
                print(err ?? "")
                return
            }
            
            self.navigationController?.pushViewController(self.viewController, animated: true)
            //self.myTopListViewController?.fetchUserAndSetupNavBarTitle()

            //self.myTopListViewController?.navigationController?.popViewController(animated: true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        view.addSubview(inputsContainerView)
        view.addSubview(profileImageView)
        
        setupNavBar()
        setupProfileImageView()
        setupInputsContainerView()
        
        fetchUserProfile()
        
        
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        // Read User information from DB
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String : AnyObject] {
                //[String : AnyObject]
                //                self.navigationItem.title = dictionary["name"] as? String

                let user = User(dictionary: dictionary)
                self.setupProfileWithUser(user: user)
            }

        }, withCancel: nil)
    }

    func setupProfileWithUser(user: User) {
        if let url = user.profileurl {
            //profileImageView.downloadImageUsingCacheWithLink(url)
            let downloadUrl = URL(string: url)!
            let downloadData = NSData(contentsOf: downloadUrl )
            let downloadPic = UIImage(data: downloadData! as Data)
            profileImageView.image = downloadPic
        }
        if let xname = user.fullname {
            fullnameTextField.text = xname
        }
        if let pname = user.username {
            usernameTextField.text = pname
            navigationItem.title = pname
        }
        if let location = user.location {
            locationTextField.text = location
        }
        
    }
    
    func setupNavBar(){
        navigationController?.navigationBar.barTintColor = UIColor.white
//        if let name = username {
//            navigationItem.title = name
//        }
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(handleUpdate))
        navigationItem.backBarButtonItem?.title = "Cancel"
    }
    
    @objc func mydismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12) .isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        inputsContainerView.addSubview(fullnameTextField)
        inputsContainerView.addSubview(fullnameSeparatorView)
        inputsContainerView.addSubview(usernameTextField)
        inputsContainerView.addSubview(usernameSeparatorView)
        inputsContainerView.addSubview(locationTextField)
        
        
        //need x, y, width, height constraints
        
        //need x, y, width, height constraints
        fullnameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        fullnameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        fullnameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        fullnameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //need x, y, width, height constraints
        fullnameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        fullnameSeparatorView.topAnchor.constraint(equalTo: fullnameTextField.bottomAnchor).isActive = true
        fullnameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        fullnameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        usernameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: fullnameTextField.bottomAnchor).isActive = true
        
        usernameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        usernameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //need x, y, width, height constraints
        usernameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        usernameSeparatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        usernameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        
        //need x, y, width, height constraints
        locationTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        locationTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        
        locationTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        locationTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
