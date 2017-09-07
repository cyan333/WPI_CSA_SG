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
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        
        guard let password = password else{
            Utils.show(alertMessage: "Unknown error", onViewController: self)
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
            if Int(classOf) == nil || classOf.characters.count != 4 {
                Utils.show(alertMessage: "Graduation year must be a four digits number", onViewController: self)
                return
            }
        }
        
        if let major = major{
            if major.characters.count > 10 {
                Utils.show(alertMessage: "Please user abbreviation for major, like CS, ECE, etc", onViewController: self)
                return
            }
        }
        
        Utils.showLoadingIndicator()
        WCUserManager.regesterSalt(forUsername: username) { (error, salt) in
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
                                                    Utils.setParam(named: savedUsername, withValue: username)
                                                    Utils.setParam(named: savedPassword,
                                                                   withValue: WCUtils.md5(password + salt))
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
    
    
    func handleDatePicker(sender: UIDatePicker) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RegisterInputCell {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YY"
            let dateStr = formatter.string(from: sender.date)
            birthday = dateStr
            cell.textField.text = dateStr
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        switch textField.tag {
        case 0:
            username = textField.text
            break
        case 1:
            name = textField.text
            break
        case 2:
            password = textField.text
            break
        case 3:
            confirm = textField.text
            break
        case 5:
            classOf = textField.text
            break
        case 6:
            major = textField.text
            break
        default:
            break
        }
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
        /*if section == 0{
            return 25
        } else if section == 1 {
            return 35
        } else {
            return 20
        }*/
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! RegisterInputCell
            cell.textField.becomeFirstResponder()
        }else if indexPath.section == 3 {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterLabelCell")!
            
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
        if section == 1 {
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
