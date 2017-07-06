//
//  RegisterViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/21/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class RegisterInputCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
}

class RegisterViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    let labelText = ["Username", "Name", "Password", "Confirm"]
    let placeHolderText = ["Your email address", "Your name", "6 characters with number and letter", "Confirm your password"]
    
    override func viewDidLoad() {
        //usernameField.becomeFirstResponder()
        /*usernameField.text = "fning@wpi.edu"
        nameField.text = "derek"
        passwordField.text = "flashvb6"
        passwordConfirmField.text = "flashvb6"*/
        //passwordField.isSecureTextEntry = true
        //passwordConfirmField.isSecureTextEntry = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
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
                                                    Utils.setParam(named: savedUsername, withValue: username)
                                                    Utils.setParam(named: savedPassword,
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
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.tableView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInset
    }
    
}

extension RegisterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            return 80
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 20
        } else if section == 1 {
            return 35
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! RegisterInputCell
            cell.textField.becomeFirstResponder()
        }
    }
}

extension RegisterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterLabelCell")!
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as! RegisterInputCell
            
            cell.textField.tag = indexPath.row
            cell.textField.delegate = self
            cell.label.text = labelText[indexPath.row]
            cell.textField.placeholder = placeHolderText[indexPath.row]
            if indexPath.row == 3 {
                cell.textField.returnKeyType = .done
            }
            return cell
        }
        
    }
    
    
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Account information"
        }else{
            return " "
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }*/
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
