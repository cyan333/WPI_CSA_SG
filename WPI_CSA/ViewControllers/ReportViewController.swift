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
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var reportTxtView: UITextView!
    @IBOutlet weak var placeHolder: UILabel!
    
    var menuId: Int?
    var reportHeightOffset: CGFloat = 120.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utils.appMode == .LoggedOn {
            emailTxtField.removeFromSuperview()
            separatorView.removeFromSuperview()
            reportHeightOffset -= 35
            let reportTxtViewTop = self.view.constraints.filter { $0.identifier == "reportTxtViewTop" }
            if let reportTxtViewTop = reportTxtViewTop.first {
                reportTxtViewTop.constant = 10
            }
            let reportPlaceHolderTop = self.view.constraints.filter { $0.identifier == "reportPlaceHolderTop" }
            if let reportPlaceHolderTop = reportPlaceHolderTop.first {
                reportPlaceHolderTop.constant = 16
            }
            
            reportTxtView.becomeFirstResponder()
        }else if let value = Utils.getParam(named: reportEmail) {
            emailTxtField.text = value
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
        var userId: Int?
        var email: String
        
        if Utils.appMode == .LoggedOn {
            userId = WCService.currentUser!.id
            email = WCService.currentUser!.username!
        } else {
            email = emailTxtField.text!.trimmingCharacters(in: .whitespaces)
            if email != "" && Utils.isEmailAddress(email: email) {
                Utils.setParam(named: reportEmail, withValue: email)
            }else if email != "" {
                let alert = UIAlertController(title: nil, message: "Please check email format", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        
        let report = reportTxtView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if report == "" {
            let alert = UIAlertController(title: nil, message: "Please enter a valid report", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Utils.showLoadingIndicator()
        WCService.reportSGProblem(forMenu: menuId!, byUser: userId, andEmail: email, withReport: report) { (error) in
            if error == "" {
                Utils.dismissIndicator()
                self.dismiss(animated: true, completion: nil)
                var toastMessage: String
                if email != "" {
                    toastMessage = "Thank you for your report. We will get back to you as soon as possible."
                }else{
                    toastMessage = "Thank you for your report. We will not get back to you since you do not have email on record."
                }
                let messageDict = ["message": toastMessage]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToast"), object: nil, userInfo: messageDict)
            }else{
                Utils.dismissIndicator()
                Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
            }
        }
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            let heightConstraint = reportTxtView.constraints.filter { $0.identifier == "reportTxtViewHeight" }
            if let heightConstraint = heightConstraint.first {
                heightConstraint.constant = UIScreen.main.bounds.height - (keyboardFrame?.height)! - reportHeightOffset
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
