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
    let editorFontSize = ["15", "17", "20", "22", "25", "30", "35", "40", "48", "56", "72"]
    let editorFontColor = ["black", "red", "blue", "yellow", "gray", "green"]
    let editorFontStyle = ["thin", "normal", "medium", "bold", "heavy"]
    let editorAlignment = ["left", "center", "right"]
    
    var currentFontSize = "17"
    var currentFontColor = "black"
    var currentFontStyle = "normal"
    var currentAlignment = "left"
    
    //var articleCellHeight: CGFloat = 300
    let placeHolderText = ["Enter title here", "Enter article here"]
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 25, 0)
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)*/
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        if let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditorTextCell,
            let articleCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditorTextCell{
            if titleCell.textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" ||
                articleCell.textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                let confirm = UIAlertController(title: nil, message: "Are you sure you want to cancel?", preferredStyle: .alert)
                confirm.addAction(UIAlertAction(title: "Yes, discard article", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }))
                confirm.addAction(UIAlertAction(title: "Yes, save article locally", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("saving")
                }))
                confirm.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(confirm, animated: true, completion: nil)
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createClicked(_ sender: Any) {
        print(2)
    }
    
    func getTextStyleString() -> String {
        return  "Text Style: " + currentFontSize + ", " + currentFontColor + ", "
            + currentFontStyle + ", " + currentAlignment
    }
    
    func applicationWillResignActive() {
        print("ending")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
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
            pickerView.selectRow(1, inComponent: 0, animated: false)
            pickerView.selectRow(1, inComponent: 2, animated: false)
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
            //cell.textView.layer.borderWidth = 1
            //cell.textView.layer.borderColor = UIColor.gray.cgColor
            print("loading cell")
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
            return 40
        }else if component == 1 {
            return 80
        }else if component == 2 {
            return 90
        }else{
            //print(self.view.bounds.width)//320
            return 80
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let cell = tableView.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? EditorTextCell {
            var textAttributes = cell.textView.typingAttributes
            
            let fontSize = CGFloat(NumberFormatter().number(from: currentFontSize)!)
            //["thin", "normal", "medium", "bold"]
            switch currentFontStyle {
            case "thin":
                textAttributes["\(NSFontAttributeName)"] = UIFont.systemFont(ofSize: fontSize,
                                                                             weight: UIFontWeightThin)
                break
            case "medium":
                textAttributes["\(NSFontAttributeName)"] = UIFont.systemFont(ofSize: fontSize,
                                                                             weight: UIFontWeightMedium)
                break
            case "bold":
                textAttributes["\(NSFontAttributeName)"] = UIFont.systemFont(ofSize: fontSize,
                                                                             weight: UIFontWeightBold)
                break
            case "heavy":
                textAttributes["\(NSFontAttributeName)"] = UIFont.systemFont(ofSize: fontSize,
                                                                             weight: UIFontWeightHeavy)
                break
            default:
                textAttributes["\(NSFontAttributeName)"] = UIFont.systemFont(ofSize: fontSize,
                                                                             weight: UIFontWeightRegular)
                break
            }
            
            switch currentFontColor {
            case "red":
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.red
                break
            case "blue":
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.blue
                break
            case "yellow":
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.yellow
                break
            case "gray":
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.gray
                break
            case "green":
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.green
                break
            default:
                textAttributes["\(NSForegroundColorAttributeName)"] = UIColor.black
                break
            }
            
            //let editorAlignment = ["left", "center", "right"]
            let paragraphStyle = NSMutableParagraphStyle()
            switch currentAlignment {
            case "center":
                paragraphStyle.alignment = .center
                break
            case "right":
                paragraphStyle.alignment = .right
                break
            default:
                paragraphStyle.alignment = .left
                break
            }
            textAttributes["\(NSParagraphStyleAttributeName)"] = paragraphStyle
            cell.textView.typingAttributes = textAttributes
        }
    }
}
