//
//  LoginViewController.swift
//  MovieList
//
//  Created by Drew Spelman on 4/9/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController{
    
    var username: String?
    //var viewController = ViewController()
    
    let loginButton: UIButton = {
        let xx = UIButton()
        xx.backgroundColor = UIColor.white
        xx.translatesAutoresizingMaskIntoConstraints = false
        xx.layer.cornerRadius = 5
        xx.layer.masksToBounds = true
        xx.setTitle("Login", for: UIControlState.normal)
        xx.setTitleColor(UIColor.blue, for: UIControlState.normal)
        xx.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        xx.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return xx
    }()
    
    var registerButton: UIButton = {
        let xx = UIButton()
        xx.backgroundColor = UIColor.white
        xx.translatesAutoresizingMaskIntoConstraints = false
        xx.layer.cornerRadius = 5
        xx.layer.masksToBounds = true
        xx.setTitle("Register", for: UIControlState.normal)
        xx.setTitleColor(UIColor.red, for: UIControlState.normal)
        xx.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        xx.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return xx
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blue
        view.addSubview(inputsContainerView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        setupInputsContainerView()
        setupLoginButton() // and register button
        setupNavBar()
    }
    @objc func handleLogin(sender: UIButton){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Must put email and password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            //successfully logged in
            let viewController = ViewController()
            //let navController = UINavigationController(rootViewController: self.ViewController!)
            //self.navigationController?.pushViewController(navController, animated: true)
            self.navigationController?.pushViewController(viewController, animated: true)
            //self.present(viewController, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            
        })
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfile))
//        navigationItem.leftBarButtonItem = backItem // This will show in the next view controller being pushed
//    }
    
//    @objc func editProfile(){
//        let profileController = ProfileController()
//        self.navigationController?.pushViewController(profileController, animated: true)
//    }
    
    @objc func handleRegister(sender: UIButton){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Must enter name, ")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            guard (user?.uid) != nil else {
                return
            }
            
            let profileController = ProfileController()
            //profileController.myTopListViewController = self.myTopListViewController
            profileController.email = email
            
            //self.navigationController?.pushViewController(profileController, animated: true)
            self.navigationController?.pushViewController(profileController, animated: true)
            //self.dismiss(animated: true, completion: nil)
        })
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -170).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginButton() {
        //need x, y, width, height constraints
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func setupNavBar(){
        navigationItem.title = "Welcome to MovieList"
        navigationController?.navigationBar.barTintColor = UIColor.white
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "editProfile", style: .plain, target: self, action: #selector(editProfile))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
