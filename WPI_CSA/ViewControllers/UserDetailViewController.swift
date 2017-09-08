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

class UserDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let labelText = ["Name", "Birthday", "Class of", "Major"]
    let placeHolderText = ["Your name", "Your birthday", "Graduation year, like 2020", "Abbreviation of your major"]
    var userDetails = [WCService.currentUser!.name, WCService.currentUser!.birthday,
                       WCService.currentUser!.classOf, WCService.currentUser!.major]
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? DetailInputCell {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YY"
            let dateStr = formatter.string(from: sender.date)
            //birthday = dateStr
            cell.textField.text = dateStr
        }
    }
    
    func addAvatar(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DetailAvatarCell {
                cell.avatar.image = chosenImage
            }
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func goBack() {
        print(1)
        navigationController?.popViewController(animated: true)
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
            let cell = tableView.cellForRow(at: indexPath) as! DetailInputCell
            cell.textField.becomeFirstResponder()
        } else {
            tableView.endEditing(true)
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
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAvatar))
            cell.avatar.addGestureRecognizer(tapGestureRecognizer)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInputCell") as! DetailInputCell
            
            cell.label.text = labelText[indexPath.row]
            cell.textField.text = userDetails[indexPath.row]
            cell.textField.placeholder = placeHolderText[indexPath.row]
            cell.textField.delegate = self
            
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
        print(1)
        return false
    }
}
