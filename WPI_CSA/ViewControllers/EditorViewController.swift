//
//  EditorViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 6/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class EditorFontCell: UITableViewCell {
    @IBOutlet weak var input: UITextField!
}

class EditorTextCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolder: UILabel!
}

class EditorViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let editorFontSize = ["10", "11", "12", "13", "14", "15", "16", "18", "20", "22", "25", "30", "35", "40", "45", "50", "60"]
    let editorFontColor = ["black", "red", "blue", "yellow", "grey", "green"]
    let editorFontStyle = ["notmal", "bold"]
    let editorAlignment = ["left", "center", "right"]
    
    var currentFontSize = "10"
    var currentFontColor = "black"
    var currentFontStyle = "noremal"
    var currentAlignment = "left"
    
    //var articleCellHeight: CGFloat = 300
    let placeHolderText = ["Enter title here", "Enter article here"]
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditorFontCell {
            if cell.input.isFirstResponder {
                print(333)
            }
        }
        print(1)
    }
    
    @IBAction func createClicked(_ sender: Any) {
        print(2)
    }
    
    func getTextStyleString() -> String {
        return  "Text Style: " + currentFontSize + "px, " + currentFontColor + ", "
            + currentFontStyle + ", " + currentAlignment
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            print(keyboardFrame?.height)
            let newCellHeight = UIScreen.main.bounds.height - (keyboardFrame?.height)! - 100
            
            /*if articleCellHeight != newCellHeight {
                print("reloaded")
                articleCellHeight = newCellHeight
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? EditorTextCell {
                    let heightConstraint = cell.textView.constraints.filter { $0.identifier == "editorTxtViewHeight" }
                    if let heightConstraint = heightConstraint.first {
                        heightConstraint.constant = UIScreen.main.bounds.height - (keyboardFrame?.height)! - reportHeightOffset
                    }
                }
            }*/
            
            
            
            
        }
    }
}

extension EditorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditorFontCell") as! EditorFontCell
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            cell.input.tintColor = .clear
            cell.input.inputView = pickerView
            cell.input.text = getTextStyleString()
            cell.input.becomeFirstResponder()
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditorTextCell") as! EditorTextCell
            cell.placeHolder.text = placeHolderText[indexPath.row - 1]
            cell.textView.tag = indexPath.row
            cell.textView.delegate = self
            cell.textView.layer.borderWidth = 1
            cell.textView.layer.borderColor = UIColor.gray.cgColor
            return cell
        }
        
    }
}

extension EditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 44
        }else if indexPath.row == 1 {
            return 60
        }else{
            return UIScreen.main.bounds.height - 360
        }
    }
}

extension EditorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return editorFontSize.count
        }else if component == 1 {
            return editorFontColor.count
        }else if component == 2 {
            return editorFontStyle.count
        }else {
            return editorAlignment.count
        }
    }
    
    
}

extension EditorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return editorFontSize[row]
        }else if component == 1 {
            return editorFontColor[row]
        }else if component == 2 {
            return editorFontStyle[row]
        }else{
            return editorAlignment[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentFontSize = editorFontSize[row]
        }else if component == 1 {
            currentFontColor = editorFontColor[row]
        }else if component == 2 {
            currentFontStyle = editorFontStyle[row]
        }else{
            currentAlignment = editorAlignment[row]
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditorFontCell {
            cell.input.text = getTextStyleString()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 35
        }else if component == 1 {
            return 70
        }else if component == 2 {
            return 85
        }else{
            //print(self.view.bounds.width)//320
            return 85
        }
    }
}

extension EditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let cell = tableView.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? EditorTextCell {
            if cell.textView.text == "" {
                cell.placeHolder.text = placeHolderText[textView.tag - 1]
            }else{
                cell.placeHolder.text = ""
            }
        }
    }
}
