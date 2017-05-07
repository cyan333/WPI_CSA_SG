//
//  ReportViewController.swift
//  WPI_CSA
//
//  Created by Cyan Xie on 5/6/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    @IBOutlet weak var reportTxtView: UITextView!
    
    
    override func viewDidLoad() {
        reportTxtView.becomeFirstResponder()
        //reportTxtView.layer.cornerRadius = 5.0
        //reportTxtView.layer.borderWidth = 0.5
        //reportTxtView.layer.borderColor = UIColor.lightGray.cgColor
        //reportTxtView.textColor = UIColor.lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("textTapped:"))
        tapGesture.numberOfTapsRequired = 1
        reportTxtView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        if reportTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            dismiss(animated: true, completion: nil)
        }else{
            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to cancel?",
                                               preferredStyle: .alert)
            
            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in})
            
            optionMenu.addAction(reportAction)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("d")
        dismiss(animated: true, completion: nil)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            let heightConstraint = reportTxtView.constraints.filter { $0.identifier == "reportTxtViewHeight" }
            if let heightConstraint = heightConstraint.first {
                heightConstraint.constant = UIScreen.main.bounds.height - (keyboardFrame?.height)! - 134
            }
        }
    }
    
    func textTapped(recognizer: UITapGestureRecognizer){
        print("tapped")
    }
    
}
