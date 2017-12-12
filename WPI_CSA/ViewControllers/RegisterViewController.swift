//
//  RegisterViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/21/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class RegisterAvatarCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
}

class RegisterInputCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
}

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let sectionOffset = 4
    let labelText = ["Username", "Name", "Password", "Confirm", "Birthday", "Class of", "Major"]
    let placeHolderText = ["Your email address", "Your name", "6 characters with number and letter", "Confirm your password", "Your birthday", "Graduation year, like 2020", "Abbreviation of your major"]
    
    var username: String?
    var name: String?
    var password: String?
    var confirm: String?
    var birthday: String?
    var classOf: String?
    var major: String?
    
    var newAvatar: UIImage?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func registerUser() {
        guard let username = username?.trimmingCharacters(in: .whitespacesAndNewlines), username != "", Utils.isEmailAddress(email: username) else{
            Utils.show(alertMessage: "Username is not a well fomatted email", onViewController: self)
            return
        }
        
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), name != "" else{
            Utils.show(alertMessage: "You must enter your name", onViewController: self)
            return
        }
        
        if name.count > 20 {
            Utils.show(alertMessage: "Name needs to be less that 20 characters", onViewController: self)
            return
        }
        
        guard let password = password else{
            Utils.show(alertMessage: "You must enter a password", onViewController: self)
            return
        }
        
        let pwdStrengthCheck = Utils.checkPasswordStrength(password: password)
        if pwdStrengthCheck != "" {
            Utils.show(alertMessage: pwdStrengthCheck, onViewController: self)
            return
        }
        
        guard let confirm = confirm, confirm == password else{
            Utils.show(alertMessage: "Two passwords don't match", onViewController: self)
            return
        }
        
        if let classOf = classOf {
            if Int(classOf) == nil || classOf.count != 4 {
                Utils.show(alertMessage: "Graduation year must be a four digits number", onViewController: self)
                return
            }
        }
        
        if let major = major{
            if major.count > 10 {
                Utils.show(alertMessage: "Please use abbreviation for major, like CS, ECE, etc", onViewController: self)
                return
            }
        }
        
        Utils.showLoadingIndicator()
        WCUserManager.registerSalt(forUsername: username) { (error, salt) in
            if error == "" {
                WCUserManager.register(forUsername: username,
                                       andEncryptedPassword: WCUtils.md5(password + salt),
                                       completion: { (error, user) in
                    if error == "" {
                        WCService.currentUser = user
                        Utils.appMode = .LoggedOn
                        WCUserManager.saveCurrentUserDetails(name: name, birthday: self.birthday, classOf: self.classOf, major: self.major, completion: { (error) in
                            if error == "" {
                                WCService.currentUser!.name = name
                                if let birthday = self.birthday {
                                    WCService.currentUser!.birthday = birthday
                                }
                                if let classOf = self.classOf {
                                    WCService.currentUser!.classOf = classOf
                                }
                                if let major = self.major {
                                    WCService.currentUser!.major = major
                                }
                                Utils.setParam(named: savedUsername, withValue: username)
                                Utils.setParam(named: savedPassword,
                                               withValue: WCUtils.md5(password + salt))
                                if let avatar = self.newAvatar {
                                    CacheManager.uploadImage(image: avatar, type: "Avatar", targetSize:  250,
                                                             completion: { (error, imgId) in
                                        if error != "" {
                                            print(error)
                                        }
                                        WCService.currentUser!.avatarId = imgId
                                        NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                        Utils.hideIndicator()
                                        OperationQueue.main.addOperation{
                                            let alert = UIAlertController(title: nil, message: "An email has been sent to " + user!.username! +
                                                " with a link to confirm your email. Please click on the link in 24 hours. " +
                                                "Please check your junk folder if you cannot see the email.", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (_) in
                                                self.dismiss(animated: true, completion: nil)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                    })
                                } else {
                                    NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                    Utils.hideIndicator()
                                    
                                    OperationQueue.main.addOperation{
                                        let alert = UIAlertController(title: nil, message: "An email has been sent to " + user!.username! +
                                            " with a link to confirm your email. Please click on the link in 24 hours. " +
                                            "Please check your junk folder if you cannot see the email.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (_) in
                                            self.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                Utils.hideIndicator()
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
                        Utils.hideIndicator()
                        Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
                    }
                })
            } else {
                Utils.hideIndicator()
                Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.tableView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInset
    }
    
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RegisterInputCell {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YY"
            let dateStr = formatter.string(from: sender.date)
            birthday = dateStr
            cell.textField.text = dateStr
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 0:
            username = textField.text
        case 1:
            name = textField.text
        case 2:
            password = textField.text
        case 3:
            confirm = textField.text
        case 5:
            classOf = textField.text
        case 6:
            major = textField.text
        default: break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.newAvatar = chosenImage
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RegisterAvatarCell {
                cell.avatar.image = chosenImage
            }
        } else{
            print("Something went wrong")//TODO: Do something?
        }
        
        self.dismiss(animated: true, completion: nil)
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
        if section == 0 {
            return 30
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.delegate = self
                imagePicker.sourceType = .savedPhotosAlbum;
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else if indexPath.section < 3 {
            let cell = tableView.cellForRow(at: indexPath) as! RegisterInputCell
            cell.textField.becomeFirstResponder()
        } else if indexPath.section == 3 {
            tableView.deselectRow(at: indexPath, animated: true)
            registerUser()
        }
    }
}

extension RegisterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        } else if section == 2 {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterAvatarCell") as! RegisterAvatarCell
            
            if let avatar = self.newAvatar {
                cell.avatar.image = avatar
            }
            
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as! RegisterInputCell
            
            cell.textField.tag = indexPath.row
            cell.textField.delegate = self
            cell.label.text = labelText[indexPath.row]
            cell.textField.placeholder = placeHolderText[indexPath.row]
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            cell.textField.inputView = nil
            if indexPath.row == 0 {
                cell.textField.isSecureTextEntry = false
                cell.textField.keyboardType = .emailAddress
            } else if indexPath.row == 2 {
                cell.textField.isSecureTextEntry = true
                cell.textField.keyboardType = .default
            } else if indexPath.row == 3 {
                cell.textField.isSecureTextEntry = true
                cell.textField.keyboardType = .default
            } else {
                cell.textField.isSecureTextEntry = false
                cell.textField.keyboardType = .default
            }
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInputCell") as! RegisterInputCell
            
            cell.textField.tag = indexPath.row + sectionOffset
            cell.textField.delegate = self
            cell.label.text = labelText[indexPath.row + sectionOffset]
            cell.textField.placeholder = placeHolderText[indexPath.row + sectionOffset]
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            cell.textField.isSecureTextEntry = false
            cell.textField.keyboardType = .default
            if indexPath.row == 0 {
                let picker = UIDatePicker()
                picker.datePickerMode = .date
                picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
                cell.textField.inputView = picker
            } else if indexPath.row == 1 {
                cell.textField.keyboardType = .numberPad
            } else{
                cell.textField.returnKeyType = .join
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonCell")!
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "avatar"
        } else if section == 1 {
            return "required"
        } else if section == 2 {
            return "optional"
        } else {
            return ""
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == labelText.count - 1 {
            textField.resignFirstResponder()
            registerUser()
        }else{
            let section = textField.tag - sectionOffset >= -1 ? 2 : 1
            let row = textField.tag - sectionOffset >= -1 ? textField.tag - sectionOffset + 1 : textField.tag + 1
            print(String(section) + " " + String(row))
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? RegisterInputCell {
                cell.textField.becomeFirstResponder()
            }
        }
        return true
    }
}
