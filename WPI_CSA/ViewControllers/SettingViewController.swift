//
//  SettingViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/13/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class SettingOfflineCell: UITableViewCell {
    @IBOutlet weak var reconnectButton: UIButton!
}

class SettingLoginCell: UITableViewCell {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
}

class SettingUserCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailVerifyLabel: UILabel!
    
}

class SettingLinkCell: UITableViewCell {
    @IBOutlet weak var linkIcon: UIImageView!
    @IBOutlet weak var linkLabel: UILabel!
}

class SettingActionCell: UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!
}


class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var oldPass = ""
    var newPass = ""
    var confirmNewPass = ""
    let changePwdController = UIAlertController(title: "Change password", message: "", preferredStyle: .alert)
    var confirmButton: UIAlertAction? = nil
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserCell),
                                               name: NSNotification.Name.init("reloadUserCell"), object: nil)
        
        changePwdController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter current password"
            textField.isSecureTextEntry = true
            textField.tag = 1
            textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
        changePwdController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter new password"
            textField.isSecureTextEntry = true
            textField.tag = 2
            textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
        changePwdController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Confirm new password"
            textField.isSecureTextEntry = true
            textField.tag = 3
            textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
        
        confirmButton = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            self.changePwdController.textFields![0].text = ""
            self.changePwdController.textFields![1].text = ""
            self.changePwdController.textFields![2].text = ""
            
            let username = WCService.currentUser!.username!
            WCUserManager.getSaltForUser(withUsername: username) { (error, salt) in
                if error == "" {
                    let encryptedNewPwd = WCUtils.md5(self.newPass + salt)
                    WCUserManager.changePassword(from: WCUtils.md5(self.oldPass + salt),
                                                 to: encryptedNewPwd,
                                                 completion: { (error, accessToken) in
                                                    if error == ""{
                                                        WCService.currentUser?.accessToken = accessToken
                                                        SGDatabase.setParam(named: "password", withValue: encryptedNewPwd)
                                                        Utils.show(alertMessage: "Done", onViewController: self)
                                                    }else{
                                                        Utils.process(errorMessage: error,
                                                                      onViewController: self,
                                                                      showingServerdownAlert: true)                                                    }
                    })
                } else {
                    Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                }
            }
        })
        confirmButton!.isEnabled = false
        changePwdController.addAction(confirmButton!)
        changePwdController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            alert -> Void in
            self.changePwdController.textFields![0].text = ""
            self.changePwdController.textFields![1].text = ""
            self.changePwdController.textFields![2].text = ""
        }))
    }
    
    func reloadUserCell() {
        OperationQueue.main.addOperation{
            self.tableView.reloadData()
        }
    }
    
    func login(){
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingLoginCell{
            let username = cell.usernameField.text!
            let password = cell.passwordField.text!
            WCUserManager.getSaltForUser(withUsername: username) { (error, salt) in
                if error == "" {
                    WCUserManager.loginUser(withUsername: username,
                                            andPassword: WCUtils.md5(password + salt),
                                            completion: { (error, user) in
                                                if error == "" {
                                                    WCService.currentUser = user
                                                    Utils.appMode = .LoggedOn
                                                    SGDatabase.setParam(named: "username", withValue: username)
                                                    SGDatabase.setParam(named: "password", withValue: WCUtils.md5(password + salt))
                                                    self.reloadUserCell()
                                                } else {
                                                    Utils.process(errorMessage: error, onViewController: self,
                                                                  showingServerdownAlert: true)
                                                }
                    })
                } else {
                    Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                }
            }
        }
    }
    
    
    func reconnect(){
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: true)
    }
    
    
    func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 1:
            oldPass = textField.text!
            break
        case 2:
            newPass = textField.text!
            break
        case 3:
            confirmNewPass = textField.text!
            break
        default:
            break
        }
        var error = ""
        if oldPass == "" {
            error = "Enter current password"
        }else{
            error = checkPasswordStrength(password: newPass)
            if error == "" && newPass != confirmNewPass {
                error = "New passwords don't match."
            }
        }
        //let paragraph = NSMutableParagraphStyle()
        //paragraph.alignment = .right
        let attributedString = NSAttributedString(string: error, attributes: [
            //NSParagraphStyleAttributeName : paragraph,
            NSForegroundColorAttributeName : UIColor.red
            ])
        changePwdController.setValue(attributedString, forKey: "attributedMessage")
        if error == "" {
            confirmButton!.isEnabled = true
        }else{
            confirmButton!.isEnabled = false
        }
    }
    
    func checkPasswordStrength(password: String) -> String{
        if password.characters.count < 6 {
            return "New password must contain at least 6 characters"
        } else {
            let letters = NSCharacterSet.letters
            let range = password.rangeOfCharacter(from: letters)
            if range != nil {
                let ints = NSCharacterSet.decimalDigits
                let intRange = password.rangeOfCharacter(from: ints)
                if intRange != nil {
                    return ""
                } else {
                    return "New password must contain at least one number"
                }
            } else {
                return "New password must contain at least one letter"
            }
        }
    }
    
}


extension SettingViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if Utils.appMode == .LoggedOn
        {
            return 4
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return 3
        }else if section == 2{
            if let user = WCService.currentUser {
                if !user.emailConfirmed {
                    return 2
                }
            }
            return 1
        }else{
            return 1
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            return Utils.appMode == .Login ? 120 : 100
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if Utils.appMode == .Offline{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingOfflineCell") as! SettingOfflineCell
                cell.reconnectButton.addTarget(self, action: #selector(reconnect), for: .touchUpInside)
                return cell
            }else if Utils.appMode == .Login {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingLoginCell") as! SettingLoginCell
                cell.usernameField.text = "synfm123@gmail.com"
                cell.passwordField.text = "flash"
                cell.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingUserCell") as! SettingUserCell
                
                let user = WCService.currentUser!
                cell.nameLabel.text = user.name
                
                cell.emailLabel.text = user.username
                
                let statusImage = NSTextAttachment()
                if user.emailConfirmed {
                    statusImage.image = UIImage(named: "verified.png")
                    statusImage.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
                    let statusString = NSAttributedString(attachment: statusImage)
                    let labelText = NSMutableAttributedString(string: "")
                    labelText.append(statusString)
                    labelText.append(NSAttributedString(string: " Verified"))
                    cell.emailVerifyLabel.attributedText = labelText
                } else {
                    statusImage.image = UIImage(named: "notVarified.png")
                    statusImage.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
                    let statusString = NSAttributedString(attachment: statusImage)
                    let labelText = NSMutableAttributedString(string: "")
                    labelText.append(statusString)
                    labelText.append(NSAttributedString(string: " Not Verified"))
                    cell.emailVerifyLabel.attributedText = labelText
                }
                
                return cell
            }
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingLinkCell") as! SettingLinkCell
            switch indexPath.row {
            case 0:
                cell.linkLabel.text = "Facebook"
                cell.linkIcon.image = UIImage(named: "Facebook.png")
                break
            case 1:
                cell.linkLabel.text = "Instagram"
                cell.linkIcon.image = UIImage(named: "Instagram.png")
                break
            case 2:
                cell.linkLabel.text = "YouTube"
                cell.linkIcon.image = UIImage(named: "YouTube.png")
                break
            default:
                break
            }
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingActionCell") as! SettingActionCell
            if indexPath.row == 0 {
                cell.actionButton.setTitle("Change Password", for: .normal)
            } else {
                cell.actionButton.setTitle("Verify Email Address", for: .normal)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingActionCell") as! SettingActionCell
            cell.actionButton.setTitle("Log out", for: .normal)
            return cell
        }
        
    }
}

extension SettingViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(NSURL(string: "https://www.facebook.com/wpi.csa") as! URL,
                                          options: [:], completionHandler: nil)
                break
            case 1:
                UIApplication.shared.open(NSURL(string: "https://www.instagram.com/wpicsa") as! URL,
                                          options: [:], completionHandler: nil)
                break
            case 2:
                UIApplication.shared.open(NSURL(string: "https://www.youtube.com/user/CSAWPI") as! URL,
                                          options: [:], completionHandler: nil)
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.present(changePwdController, animated: true, completion: nil)
            }else{
                WCUserManager.sendEmailConfirmation(completion: { (error) in
                    if error == "" {
                        Utils.show(alertMessage: "An email has been sent to " + WCService.currentUser!.username! +
                                    " with a link to confirm your email. Please click on the link in 24 hours. " +
                                    "Please check your junk folder if you cannot see the email.",
                                   onViewController: self)
                    }else{
                        Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                    }
                })
            }
        } else if indexPath.section == 3 {
            let confirm = UIAlertController(title: "Are you sure", message: "Your credentials will be removed",
                                            preferredStyle: .alert)
            
            confirm.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                WCService.currentUser = nil
                Utils.appMode = .Login
                SGDatabase.deleteParam(named: "username")
                SGDatabase.deleteParam(named: "password")
                tableView.reloadData()
            }))
            confirm.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(confirm, animated: true, completion: nil)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if Utils.appMode == .Login {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingLoginCell{
                cell.usernameField.resignFirstResponder()
                cell.passwordField.resignFirstResponder()
            }
        }
    }
}
