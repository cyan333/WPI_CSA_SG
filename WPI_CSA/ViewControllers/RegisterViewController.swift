//
//  RegisterViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/21/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    override func viewDidLoad() {
        usernameField.becomeFirstResponder()
        passwordField.isSecureTextEntry = true
        passwordConfirmField.isSecureTextEntry = true
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        let username = usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if username == "" || !Utils.isEmailAddress(email: username) {
            errorLabel.text = "Username is not a well fomatted email"
            return
        }
        
        let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if name == "" {
            errorLabel.text = "You must enter your name"
            return
        }
        
        let pwdStrengthCheck = Utils.checkPasswordStrength(password: passwordField.text!)
        if pwdStrengthCheck != "" {
            errorLabel.text = pwdStrengthCheck
            return
        }
        
        if passwordField.text! != passwordConfirmField.text! {
            errorLabel.text = "Two passwords don't match"
            return
        }
        errorLabel.text = ""
        
        WCUserManager.regesterSalt(forUsername: username) { (error, salt) in
            if error == "" {
                
            } else {
                Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
            }
        }
    }
    
    
}
