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
        //usernameField.becomeFirstResponder()
        usernameField.text = "fning@wpi.edu"
        nameField.text = "derek"
        passwordField.text = "flashvb6"
        passwordConfirmField.text = "flashvb6"
        passwordField.isSecureTextEntry = true
        passwordConfirmField.isSecureTextEntry = true
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
        let when = DispatchTime.now() + 4 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
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
        
        Utils.showLoadingIndicator()
        WCUserManager.regesterSalt(forUsername: username) { (error, salt) in
            if error == "" {
                WCUserManager.register(forUsername: username,
                                       andEncryptedPassword: WCUtils.md5(self.passwordField.text! + salt),
                                       completion: { (error, user) in
                                        if error == "" {
                                            WCService.currentUser = user
                                            Utils.appMode = .LoggedOn
                                            WCUserManager.saveCurrentUserDetails(realName: name, completion: { (error) in
                                                if error == "" {
                                                    WCService.currentUser!.name = name
                                                    SGDatabase.setParam(named: savedUsername, withValue: username)
                                                    SGDatabase.setParam(named: savedPassword,
                                                                        withValue: WCUtils.md5(self.passwordField.text! + salt))
                                                    NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                                    Utils.dismissIndicator()
                                                    OperationQueue.main.addOperation{
                                                        let alert = UIAlertController(title: nil, message: "An email has been sent to " + user!.username! +
                                                            " with a link to confirm your email. Please click on the link in 24 hours. " +
                                                            "Please check your junk folder if you cannot see the email.", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (_) in
                                                            self.dismiss(animated: true, completion: nil)
                                                        }))
                                                        self.present(alert, animated: true, completion: nil)
                                                    }
                                                }else{
                                                    NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                                    Utils.dismissIndicator()
                                                    OperationQueue.main.addOperation{
                                                        let alert = UIAlertController(title: nil, message: "User created but name is not stored correctly. " + error, preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (_) in
                                                            self.dismiss(animated: true, completion: nil)
                                                        }))
                                                        self.present(alert, animated: true, completion: nil)
                                                    }
                                                }
                                                
                                            })
                                        }else{
                                            Utils.dismissIndicator()
                                            Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                                        }
                })
            } else {
                Utils.dismissIndicator()
                Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
            }
        }
    }
    
    
}
