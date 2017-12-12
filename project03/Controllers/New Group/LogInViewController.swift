//
//  LogInViewController.swift
//  Project_W
//
//  Created by Abhi Singh on 11/6/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    var userZipcode = ""
    let ref = Database.database().reference(withPath: "UserInfo")
    var currentUser: ConsumerInfo?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBAction func signInButton(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!,
                           password: passwordTextField.text!)
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!{
            let addAlert = UIAlertController(title: "Error!", message: "Please enter email and password", preferredStyle: .alert)
            
            addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(addAlert, animated: true, completion: nil)
        }
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            var userItem: ConsumerInfo?
            if user != nil {
                // 3
                User.sharedInstance.uid = (user?.uid)!
                if user?.email != nil {
                    User.sharedInstance.email = (user?.email)!
                }
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.performSegue(withIdentifier: "showCatalog", sender: nil)
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register",
                                      message: "Please enter below",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let zipcodeField = alert.textFields![2]
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
//                let addAlert = UIAlertController(title: "Error! what the fuck", message: error?.localizedDescription, preferredStyle: .alert)
//
//                addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(addAlert, animated: true, completion: nil)
                self.userZipcode = zipcodeField.text!
                if error == nil {
                    //Initialize user data
                    User.sharedInstance.uid = user!.uid
                    User.sharedInstance.email = user!.email!
                    User.sharedInstance.zipcode = zipcodeField.text!
                    let userRef = self.ref.child(user!.uid)
                    self.currentUser = ConsumerInfo(uid: (user?.uid)!, email: (user?.email)!,ref: self.ref, key: "", zipCode: self.userZipcode, favorite: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10", "decoy-pinot-noir-sonoma-county-2011"], cart: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10" : 2, "decoy-pinot-noir-sonoma-county-2011":3])
//                    self.currentUser = ConsumerInfo(uid: (user?.uid)!, email: (user?.email)!,ref: self.ref, key: "", zipCode: "94089", favorite: ["n/a"], cart: ["n/a":0])
//                    let userItem = ConsumerInfo(uid: user!.uid, email: user!.email!, ref: self.ref, key: "", zipCode: self.userZipcode, favorite: ["n/a"], cart: ["n/a" : 0])
                    
                    userRef.setValue(self.currentUser?.toAnyObject())
                    
                    Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                       password: self.passwordTextField.text!)
//                    self.performSegue(withIdentifier: "LoginUser", sender: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextField { textZipcode in
            textZipcode.placeholder = "Enter your zipcode"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        zipCodeTextField.delegate = self
        
        //Google Login Start//
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil{
                //IF LOGIN IS VENDOR/
                if user?.email == "juntomlee@gmail.com"{
                    User.sharedInstance.uid = (user?.uid)!
                    User.sharedInstance.email = (user?.email)!
                    //**** Need to check firebase if user exits**//
                    
//                    
//                    self.currentUser = ConsumerInfo(uid: (user?.uid)!, email: (user?.email)!,ref: self.ref, key: "", zipCode: "94089", favorite: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10", "decoy-pinot-noir-sonoma-county-2011"], cart: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10" : 2, "decoy-pinot-noir-sonoma-county-2011":3])
//                    let userUidRef = self.ref.child(user!.uid)
//                    
//                    userUidRef.setValue(self.currentUser?.toAnyObject())
                    self.performSegue(withIdentifier: "vendorView", sender: nil)
                    //Customer Login
                } else if user?.email != "n/a"{
                    User.sharedInstance.uid = (user?.uid)!
                    if user?.email != nil {
                        User.sharedInstance.email = (user?.email)!
                    } else {
                        User.sharedInstance.email = ""
                    }
                    //**** Need to check firebase if user exits**//
                    let userRef = self.ref.queryOrdered(byChild: "uid").queryEqual(toValue: User.sharedInstance.uid)
                    
                    var userItem: ConsumerInfo?
                    userRef.observe(.value, with: { snapshot in
                        for item in snapshot.children {
                            userItem = ConsumerInfo(snapshot: item as! DataSnapshot)
                            if userItem?.uid != nil {
                                print("Hello there")
//                                self.performSegue(withIdentifier: "LoginUser", sender: nil)
                            } else {
                                self.currentUser = ConsumerInfo(uid: User.sharedInstance.uid, email: User.sharedInstance.email,ref: self.ref, key: "", zipCode: self.userZipcode, favorite: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10", "decoy-pinot-noir-sonoma-county-2011"], cart: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10" : 2, "decoy-pinot-noir-sonoma-county-2011":3])
                            }
                        }
                    })
                    self.performSegue(withIdentifier: "showCatalog", sender: nil)

                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  BUTTON:
    @IBOutlet weak var continueButton: UIButton!
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if (zipCodeTextField.text?.count)! < 5 {
            //throw alert?
            zipCodeTextField.text? = "Please enter a valid zip code."
        } else {
            // if zipCodeTextField.text != "" {
            
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print("Error Here: \(err.localizedDescription)")
                    return
                }
                // if signInAnonymouslyWithCompletion: method completes without error, you can get the anonymous user's account data from the FIRUser object:
                if user!.isAnonymous {
                    // let uid = user!.uid
                    guard let text = self.zipCodeTextField.text else {
                        return
                    }
                    let userInfo = ConsumerInfo(uid: user!.uid, email: "n/a", ref: self.ref, key: "", zipCode: text, favorite: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10", "decoy-pinot-noir-sonoma-county-2011"], cart: ["chateau-pontet-canet-red-bordeaux-blend-pauillac-2011-10" : 5, "decoy-pinot-noir-sonoma-county-2011":3])
                    print("%%%%%%%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                    
                    let userUidRef = self.ref.child(user!.uid)
                    userUidRef.setValue(userInfo.toAnyObject())
//                    self.performSegue(withIdentifier: "LoginUser", sender: nil)
                }
            })
        }
    }
    
    private func disabledButtonState() {
        if (zipCodeTextField.text?.count)! < 5 {
            continueButton.isEnabled = false
        }
    }
    
    private func updateButtonState() {
        let text = zipCodeTextField.text ?? ""
        continueButton.isEnabled = !text.isEmpty
    }

    //TEXTFIELDDZ
    func textFieldDidBeginEditing(_ textField: UITextField) {
        continueButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let actualTF = textField.text ?? ""

        // error message if user-inputted zipcode in TF not 5 digits
        if actualTF.count != 5 {
            textField.resignFirstResponder()
            zipCodeTextField.text? = "Please enter a valid zip code."
            //updateButtonState()
            return false
        } else {
            textField.resignFirstResponder()
            updateButtonState()
            self.view.endEditing(true)
            return true
        }
    }
}
