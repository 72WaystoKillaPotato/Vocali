//
//  LoginViewController.swift
//  Technovation
//
//  Created by Samantha Su on 4/25/20.
//  Copyright © 2020 Vicky Liu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController:UIViewController, UITextFieldDelegate{
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var activeTextField: UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatUI()
        errorLabel.alpha = 0
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);

        Auth.auth().addStateDidChangeListener { auth, user in
          if let user = user {
            print("automatically signed in with UID: \(user.uid)")
            Constants.uID = user.uid
            Firestore.firestore().settings = FirestoreSettings()
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(Constants.uID!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    Constants.points = document.get("points") as? Int
                    Constants.purchasedItem = document.get("purchasedItem") as? Array ?? ["face1", "head1"]
                    Constants.wearingItem = document.get("wearingItem") as? [String: String] ?? [Item.items[2].type.rawValue: Item.items[2].name, Item.items[12].type.rawValue: Item.items[12].name]
                    
                    print("wearingItems = ", Constants.wearingItem)
                    /*
                    Constants.avatarName = document.get("avatarName") as? String
                    print("Document data: points \(String(describing: Constants.points)), avatarName \(String(describing: Constants.avatarName))")
                    */
                } else {
                    print("Document does not exist")
                }
            }
            self.transitionToHome()
          }
        }
    }
    
    func formatUI(){
        formatTextField(textField: emailTextField, placeholder: "email")
        formatTextField(textField: passwordTextField, placeholder: "password")
        formatButton(button: loginButton)
        formatButton(button: signupButton)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @IBAction func didLogin(_ sender: Any) {
        //setting up Firestore for data retrieval
        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }else{
                //retrieve previously stored data from Firebase
                Constants.uID = result!.user.uid
                let docRef = db.collection("users").document(Constants.uID!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        Constants.points = document.get("points") as? Int
                        /*Constants.avatarName = document.get("avatarName") as? String
                        print("Document data: points \(String(describing: Constants.points)), avatarName \(String(describing: Constants.avatarName))")*/
                    } else {
                        print("Document does not exist")
                    }
                }
                self.transitionToHome()
            }
        }
    }
    
    func transitionToHome(){
        let tableViewController = storyboard?.instantiateViewController(identifier: "MainVC")
        let nav = UINavigationController()
        nav.viewControllers = [tableViewController!]
        
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
}

