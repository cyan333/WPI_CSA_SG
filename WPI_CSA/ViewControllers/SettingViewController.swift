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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
}

class SettingUserCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
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
        super.viewDidLoad()
        
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
            
            Utils.showLoadingIndicator()
            WCUserManager.changePassword(from: self.oldPass, to: self.newPass) { (error) in
                if error == "" {
                    Utils.hideIndicator()
                    Utils.show(alertMessage: "Done", onViewController: self)
                    
                } else {
                    Utils.hideIndicator()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(showToast(_:)),
                                               name: NSNotification.Name.init("showToastOnSetting"), object: nil)
    }
    
    @objc func showToast(_ notification: NSNotification) {
        if let message = notification.userInfo?["message"] as? String {
            var style = ToastStyle()
            style.messageAlignment = .center
            DispatchQueue.main.async {
                self.view.makeToast(message, duration: 3.0, position: .center, style: style)
            }
        }
        
    }
    
    @objc func reloadUserCell() {
        OperationQueue.main.addOperation{
            self.tableView.reloadData()
        }
    }
    
    @objc func login(){
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingLoginCell{
            let username = cell.usernameField.text!
            let password = cell.passwordField.text!
            
            if username.trim() == "" {
                Utils.show(alertMessage: "Please enter your username.", onViewController: self)
                return
            }
            if password.trim() == "" {
                Utils.show(alertMessage: "Please enter your password.", onViewController: self)
                return
            }
            
            Utils.showLoadingIndicator()
            WCUserManager.loginUser(withUsername: username, andPassword: password) { (error, user) in
                if error == "" {
                    Utils.appMode = .LoggedOn
                    Utils.hideIndicator()
                    self.reloadUserCell()
                } else {
                    Utils.hideIndicator()
                    Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                }
            }
        }
    }
    
    @objc func forget() {
        let resetPwdController = UIAlertController(title: "Enter your username (email)", message: "", preferredStyle: .alert)
        resetPwdController.addTextField { (textField : UITextField!) -> Void in }
        resetPwdController.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            alert -> Void in
            let email = resetPwdController.textFields![0].text!.trim()
            if(email == "") {
                Utils.show(alertMessage: "Please enter a valid username", onViewController: self)
            } else {
                Utils.showLoadingIndicator()
                WCUserManager.resetPassword(for: email, completion: { (error) in
                    Utils.hideIndicator()
                    if error == "" {
                        Utils.show(alertMessage: "An email has been sent to \(email) with a link to reset your password. Please click on the link in 24 hours. Please check your junk folder if you cannot see the email.", onViewController: self)
                    } else {
                        Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                    }
                })
            }
        }))
        resetPwdController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(resetPwdController, animated: true, completion: nil)
    }
    
    @objc func reconnect(){
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: true)
    }
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 1:
            oldPass = textField.text!
        case 2:
            newPass = textField.text!
        case 3:
            confirmNewPass = textField.text!
        default: break
        }
        var error = ""
        if oldPass == "" {
            error = "Enter current password"
        }else{
            error = Utils.checkPasswordStrength(password: newPass)
            if error == "" && newPass != confirmNewPass {
                error = "New passwords don't match."
            }
        }
        
        if error == "" {
            confirmButton!.isEnabled = true
        }else{
            confirmButton!.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UserDetailViewController {
            destinationViewController.delegate = self
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
                cell.usernameField.tag = 0
                cell.usernameField.delegate = self
                cell.passwordField.tag = 1
                cell.passwordField.delegate = self
                cell.passwordField.isSecureTextEntry = true
                cell.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
                cell.forgetButton.addTarget(self, action: #selector(forget), for: .touchUpInside)
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
                    statusImage.image = UIImage(named: "notVerified.png")
                    statusImage.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
                    let statusString = NSAttributedString(attachment: statusImage)
                    let labelText = NSMutableAttributedString(string: "")
                    labelText.append(statusString)
                    labelText.append(NSAttributedString(string: " Not Verified"))
                    cell.emailVerifyLabel.attributedText = labelText
                }
                
                if let avatarId = user.avatarId {
                    CacheManager.getImage(withName: avatarId.toWCImageId(), completion: { (error, img) in
                        DispatchQueue.main.async {
                            cell.avatar.image = img
                        }
                    })
                } else {
                    cell.avatar.image = #imageLiteral(resourceName: "defaultAvatar.png")
                }
                
                return cell
            }
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingLinkCell") as! SettingLinkCell
            switch indexPath.row {
            case 0:
                cell.linkLabel.text = "Facebook"
                cell.linkIcon.image = UIImage(named: "Facebook.png")
            case 1:
                cell.linkLabel.text = "Instagram"
                cell.linkIcon.image = UIImage(named: "Instagram.png")
            case 2:
                cell.linkLabel.text = "YouTube"
                cell.linkIcon.image = UIImage(named: "YouTube.png")
            default: break
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
        if indexPath.section == 0 {
            if tableView.cellForRow(at: indexPath) is SettingUserCell {
                self.performSegue(withIdentifier: "UserDetailSegue", sender: nil)
            }
            
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "https://www.facebook.com/wpi.csa")!,
                                              options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "https://www.facebook.com/wpi.csa")!)
                }
            case 1:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "https://www.instagram.com/wpicsa")!,
                                              options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "https://www.instagram.com/wpicsa")!)
                }
            case 2:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "https://www.youtube.com/user/CSAWPI")!,
                                              options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "https://www.youtube.com/user/CSAWPI")!)
                }
            default: break
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
                                            preferredStyle: .actionSheet)
            
            confirm.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                WCService.currentUser = nil
                Utils.appMode = .Login
                Utils.deleteParam(named: savedAccessToken)
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

extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            login()
        }else{
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingLoginCell {
                cell.passwordField.becomeFirstResponder()
            }
        }
        return true
    }
}

extension SettingViewController: UserDetailViewControllerDelegate {
    func updateUserDetails() {
        reloadUserCell()
    }
}
