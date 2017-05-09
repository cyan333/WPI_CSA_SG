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
    
    var db: SGDatabase?
    
    override func viewDidLoad() {
        do{
            db = try SGDatabase.connect()
            if let value = db!.getParam(named: "email") {
                emailTxtField.text = value
                reportTxtView.becomeFirstResponder()
            }else{
                emailTxtField.becomeFirstResponder()
            }
        }catch{
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
            let confirm = UIAlertController(title: nil,
                                            message: "Are you sure you want to cancel?",
                                            preferredStyle: .alert)
            
            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            confirm.addAction(reportAction)
            confirm.addAction(cancelAction)
            
            self.present(confirm, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        let email = emailTxtField.text!.trimmingCharacters(in: .whitespaces)
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        if email != "" && emailTest.evaluate(with: email) {
            if let db = db {
                db.setParam(named: "email", withValue: email)
            }
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
        print("send")
        /*
        
        dismiss(animated: true, completion: nil)*/
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
