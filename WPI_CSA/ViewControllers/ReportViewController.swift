//
//  ReportViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/6/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var reportTxtView: UITextView!
    @IBOutlet weak var placeHolder: UILabel!
    
    var menuId: Int?
    
    override func viewDidLoad() {
        if let user = WCService.currentUser {
            emailTxtField.text = user.username
            reportTxtView.becomeFirstResponder()
        }else if let value = SGDatabase.getParam(named: "email") {
            emailTxtField.text = value
            
            var attributes = reportTxtView.typingAttributes
            attributes["\(NSForegroundColorAttributeName)"] = UIColor.red
            reportTxtView.typingAttributes = attributes
            reportTxtView.becomeFirstResponder()
        }else{
            emailTxtField.becomeFirstResponder()
        }
        reportTxtView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        if reportTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            dismiss(animated: true, completion: nil)
        }else{
            let confirm = UIAlertController(title: nil, message: "Are you sure you want to cancel?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            }))
            confirm.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(confirm, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        let email = emailTxtField.text!.trimmingCharacters(in: .whitespaces)
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        if email != "" && emailTest.evaluate(with: email) {
            SGDatabase.setParam(named: "email", withValue: email)
        }else if email != "" {
            let alert = UIAlertController(title: nil, message: "Please check email format", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let report = reportTxtView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if report == "" {
            let alert = UIAlertController(title: nil, message: "Please enter a valid report", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        WCService.reportSGProblem(forMenu: menuId!, byUser: email, withReport: report) { (error) in
            if error != "" {
                OperationQueue.main.addOperation{
                    let alert = UIAlertController(title: "Something goes wrong", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            let heightConstraint = reportTxtView.constraints.filter { $0.identifier == "reportTxtViewHeight" }
            if let heightConstraint = heightConstraint.first {
                heightConstraint.constant = UIScreen.main.bounds.height - (keyboardFrame?.height)! - 120
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeHolder.text = "Enter your report"
        }else{
            placeHolder.text = ""
        }
    }
    
}
