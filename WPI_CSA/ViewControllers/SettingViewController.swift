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
    //var loginMode = true
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserCell),
                                               name: NSNotification.Name.init("reloadUserCell"), object: nil)
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
                if error != serverDown {
                    Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                    return
                }
                WCUserManager.loginUser(withUsername: username,
                                        andPassword: WCUtils.md5(password + salt),
                                        completion: { (error, user) in
                                            if error != "" {
                                                Utils.process(errorMessage: error, onViewController: self,
                                                              showingServerdownAlert: true)
                                            } else {
                                                WCService.currentUser = user
                                                
                                                SGDatabase.setParam(named: "username", withValue: username)
                                                SGDatabase.setParam(named: "password", withValue: WCUtils.md5(password + salt))
                                                self.reloadUserCell()
                                            }
                })
            }
        }
    }
    
    
    func reconnect(){
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: true)
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
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                tableView.deselectRow(at: indexPath, animated: true)
                UIApplication.shared.open(NSURL(string: "https://www.facebook.com/wpi.csa") as! URL,
                                          options: [:], completionHandler: nil)
                break
            case 1:
                tableView.deselectRow(at: indexPath, animated: true)
                UIApplication.shared.open(NSURL(string: "https://www.instagram.com/wpicsa") as! URL,
                                          options: [:], completionHandler: nil)
                break
            case 2:
                tableView.deselectRow(at: indexPath, animated: true)
                UIApplication.shared.open(NSURL(string: "https://www.youtube.com/user/CSAWPI") as! URL,
                                          options: [:], completionHandler: nil)
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                print("pwd")
                WCUserManager.saveCurrentUserDetails(realName: "Fangming Ning", completion: { (error) in
                    if error != "" {
                        print(error)
                    }
                })
            }else{
                print("verufy")
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
            
            tableView.deselectRow(at: indexPath, animated: true)
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
