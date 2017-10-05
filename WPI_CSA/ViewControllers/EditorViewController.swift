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
    
    let placeHolderText = ["Enter title here", "Enter article here"]
    var savedArticle = ["", ""]
    var menuId: Int?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 250, 0)
        
        if let title = Utils.getParam(named: localTitle) {
            savedArticle[0] = title
        }
        if let article = Utils.getParam(named: localArticle) {
            savedArticle[1] = article
        }
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
                    Utils.setParam(named: localTitle, withValue: "")
                    Utils.setParam(named: localArticle, withValue: "")
                    self.dismiss(animated: true, completion: nil)
                }))
                confirm.addAction(UIAlertAction(title: "Yes, save article locally", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.saveArticle(title: titleCell.textView.attributedText, article: articleCell.textView.attributedText)
                    self.dismiss(animated: true, completion: nil)
                }))
                confirm.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(confirm, animated: true, completion: nil)
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getTextStyleString() -> String {
        return  "Text Style: " + currentFontSize + ", " + currentFontColor + ", "
            + currentFontStyle + ", " + currentAlignment
    }
    
    func saveArticle(title: NSAttributedString, article: NSAttributedString) {
        if title.length > 0 {
            if let title = title.htmlString() {
                Utils.setParam(named: localTitle, withValue: title)
            }
        }else{
            Utils.setParam(named: localTitle, withValue: "")
        }
        if article.length > 0 {
            if let article = article.htmlString() {
                Utils.setParam(named: localArticle, withValue: article)
            }
        }else{
            Utils.setParam(named: localArticle, withValue: "")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditorTextCell,
            let articleCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditorTextCell{
            self.saveArticle(title: titleCell.textView.attributedText, article: articleCell.textView.attributedText)
            if let destinationViewController = segue.destination as? PreviewViewController {
                destinationViewController.attributedTitle = titleCell.textView.attributedText
                destinationViewController.attributedArtile = articleCell.textView.attributedText
                destinationViewController.menuId = menuId
            }
        }
    }
    
    @objc func applicationWillResignActive() {
        if let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditorTextCell,
            let articleCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditorTextCell{
            self.saveArticle(title: titleCell.textView.attributedText, article: articleCell.textView.attributedText)
        }
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
            cell.textView.tag = indexPath.row
            cell.textView.delegate = self
            //cell.textView.layer.borderWidth = 1
            //cell.textView.layer.borderColor = UIColor.gray.cgColor
            cell.textView.attributedText = savedArticle[indexPath.row - 1].htmlAttributedString(ratio: .Normal)
            if savedArticle[indexPath.row - 1] == "" {
                cell.placeHolder.text = placeHolderText[indexPath.row - 1]
            }
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
        //minimum required width for each wheel is 40, 80, 100, 80 on a minimum screen witdh of 320 (iphone 5)
        //So applying the offset 320 - 300 = 20 and then calculate width by the ratio
        let screenWidth = UIScreen.main.bounds.width - 20
        if component == 0 {
            return screenWidth * 2 / 15
        }else if component == 1 {
            return screenWidth * 4 / 15
        }else if component == 2 {
            return screenWidth * 5 / 15
        }else{
            return screenWidth * 4 / 15
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
            
            let fontSize = CGFloat(truncating: NumberFormatter().number(from: currentFontSize)!)
            
            switch currentFontStyle {
            case "thin":
                if #available(iOS 8.2, *) {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont.systemFont(ofSize: fontSize,
                                                                                 weight: UIFont.Weight.thin)
                    
                } else {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont(name: "HelveticaNeue-Thin", size: fontSize)
                }
            case "medium":
                if #available(iOS 8.2, *) {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont.systemFont(ofSize: fontSize,
                                                                                 weight: UIFont.Weight.medium)
                } else {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont(name: "HelveticaNeue-Medium", size: fontSize)
                }
            case "bold":
                if #available(iOS 8.2, *) {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont.systemFont(ofSize: fontSize,
                                                                                 weight: UIFont.Weight.bold)
                } else {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
                }
            case "heavy":
                if #available(iOS 8.2, *) {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont.systemFont(ofSize: fontSize,
                                                                                 weight: UIFont.Weight.heavy)
                } else {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
                }
            default:
                if #available(iOS 8.2, *) {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont.systemFont(ofSize: fontSize,
                                                                                 weight: UIFont.Weight.regular)
                } else {
                    textAttributes["\(NSAttributedStringKey.font)"] = UIFont(name: "HelveticaNeue", size: fontSize)
                }
            }
            
            switch currentFontColor {
            case "red":
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.red
            case "blue":
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.blue
            case "yellow":
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.yellow
            case "gray":
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.gray
            case "green":
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.green
            default:
                textAttributes["\(NSAttributedStringKey.foregroundColor)"] = UIColor.black
            }
            
            //let editorAlignment = ["left", "center", "right"]
            let paragraphStyle = NSMutableParagraphStyle()
            switch currentAlignment {
            case "center":
                paragraphStyle.alignment = .center
            case "right":
                paragraphStyle.alignment = .right
            default:
                paragraphStyle.alignment = .left
            }
            textAttributes["\(NSAttributedStringKey.paragraphStyle)"] = paragraphStyle
            cell.textView.typingAttributes = textAttributes
        }
    }
}
