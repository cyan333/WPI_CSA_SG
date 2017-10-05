//
//  UserDetailViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 9/6/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class DetailAvatarCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
}

class DetailInputCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
}

protocol UserDetailViewControllerDelegate
{
    func updateUserDetails()
}

class UserDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var avatarChanged = false
    var delegate: UserDetailViewControllerDelegate?
    
    let labelText = ["Name", "Birthday", "Class of", "Major"]
    let placeHolderText = ["Your name", "Your birthday", "Graduation year, like 2020", "Abbreviation of your major"]
    var userDetails = [WCService.currentUser!.name, WCService.currentUser!.birthday,
                       WCService.currentUser!.classOf, WCService.currentUser!.major]
    var userDetailsOriginal = [String]()
    
    var newAvatar: UIImage?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDetailsOriginal = userDetails
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        
        let button =  UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 31)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(-1, -12, 1, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake(-1, -10, 1, 0)
        button.setTitle("Setting", for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        let newBackButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = newBackButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
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
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? DetailInputCell {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YY"
            let dateStr = formatter.string(from: sender.date)
            userDetails[1] = dateStr
            cell.textField.text = dateStr
        }
    }
    
    @objc func addAvatar(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DetailAvatarCell {
                avatarChanged = true
                cell.avatar.image = chosenImage
                self.newAvatar = chosenImage
            }
        } else{
            print("Something went wrong")//TODO: Do something?
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        tableView.endEditing(true)
        var userDetailChanged = false
        var userDetailUpdated = false
        var avatarUpdated = false
        for i in 0 ..< userDetails.count {
            if userDetails[i].trim() != userDetailsOriginal[i] {
                userDetailChanged = true
                break
            }
        }
        
        if userDetailChanged {
            let name = userDetails[0].trim()
            let birthday = userDetails[1].trim()
            let classOf = userDetails[2].trim()
            let major = userDetails[3].trim()
            
            if name == "" {
                Utils.show(alertMessage: "You must enter your name", onViewController: self)
                return
            }
            if name.count > 20 {
                Utils.show(alertMessage: "Name needs to be less that 20 characters", onViewController: self)
                return
            }
            
            if Int(classOf) == nil || classOf.characters.count != 4 {
                Utils.show(alertMessage: "Graduation year must be a four digits number", onViewController: self)
                return
            }
            
            if major.count > 10 {
                Utils.show(alertMessage: "Please use abbreviation for major, like CS, ECE, etc", onViewController: self)
                return
            }
            
            Utils.showLoadingIndicator()
            WCUserManager.saveCurrentUserDetails(name: name, birthday: birthday, classOf: classOf, major: major,
                                                 completion: { (error) in
                                                    if error != "" {
                                                        print(error)//TODO: do something
                                                    } else {
                                                        WCService.currentUser?.name = name
                                                        WCService.currentUser?.birthday = birthday
                                                        WCService.currentUser?.classOf = classOf
                                                        WCService.currentUser?.major = major
                                                    }
                                                    userDetailUpdated = true
                                                    
                                                    if avatarUpdated {
                                                        DispatchQueue.main.async {
                                                            Utils.dismissIndicator()
                                                            self.navigationController?.popViewController(animated: true)
                                                            let messageDict = ["message": "Saved successfully"]//TODO: Error?
                                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToastOnSetting"), object: nil, userInfo: messageDict)
                                                            self.delegate?.updateUserDetails()
                                                        }
                                                    }
                                                    
                                                    
            })
        } else {
            userDetailUpdated = true
        }
        
        if avatarChanged {
            Utils.showLoadingIndicator()
            let a = UIImage(named: "test.jpg")
            CacheManager.uploadImage(image: a!, type: "Avatar", targetSize:  250,
                                     completion: { (error, imgId) in
                if error != "" {
                    print(error)
                }
                WCService.currentUser?.avatarId = imgId
                avatarUpdated = true
                
                if userDetailUpdated {
                    DispatchQueue.main.async {
                        Utils.dismissIndicator()
                        self.navigationController?.popViewController(animated: true)
                        let messageDict = ["message": "Saved successfully"]//TODO: Error?
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToastOnSetting"), object: nil, userInfo: messageDict)
                        self.delegate?.updateUserDetails()
                    }
                }
            })
        } else {
            avatarUpdated = true
        }
        
        if !userDetailChanged && !avatarChanged{
            navigationController?.popViewController(animated: true)
            let messageDict = ["message": "Nothing is changed"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToastOnSetting"), object: nil, userInfo: messageDict)
        }
    }
    
    @objc func goBack() {
        for i in 0 ..< userDetails.count {
            if userDetails[i].trim() != userDetailsOriginal[i] || avatarChanged {
                let alert = UIAlertController(title: nil, message: "You have unsaved changes. Are you sure about discarding them?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        userDetails[textField.tag] = textField.text!
    }
}

extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            return 120
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! DetailInputCell
            cell.textField.becomeFirstResponder()
        } else {
            tableView.endEditing(true)
            addAvatar()
        }
    }
}

extension UserDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailAvatarCell") as! DetailAvatarCell
            
            if let avatarId = WCService.currentUser?.avatarId {
                CacheManager.getImage(withName: avatarId.toWCImageId(), completion: { (error, img) in
                    DispatchQueue.main.async {
                        cell.avatar.image = img
                    }
                })
            } else {
                cell.avatar.image = #imageLiteral(resourceName: "defaultAvatar.png")
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAvatar))
            cell.avatar.addGestureRecognizer(tapGestureRecognizer)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInputCell") as! DetailInputCell
            
            cell.label.text = labelText[indexPath.row]
            cell.textField.tag = indexPath.row
            cell.textField.text = userDetails[indexPath.row]
            cell.textField.placeholder = placeHolderText[indexPath.row]
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            if indexPath.row == 1 {
                let picker = UIDatePicker()
                picker.datePickerMode = .date
                picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
                
                if userDetails[indexPath.row] != "" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yy"
                    if let convertedStartDate = dateFormatter.date(from: userDetails[indexPath.row]) {
                        picker.date = convertedStartDate
                    }
                }
                
                cell.textField.inputView = picker
            } else if indexPath.row == 2 {
                cell.textField.inputView = nil
                cell.textField.keyboardType = .numberPad
            } else {
                cell.textField.inputView = nil
                cell.textField.keyboardType = .default
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
}

extension UserDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView.endEditing(true)
        return true
    }
}

extension UserDetailViewController : UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        return false
    }
}
