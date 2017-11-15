//
//  FeedEditorViewController.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/12/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class FeedEditorViewController: UIViewController {
    
    var feedType = "Blog"
    var titleView: UIView!
    var editorView: UIView!
    
    var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = screenWidth - 40
        
        titleView = UIView(frame: CGRect(x: 20, y: 50, width: viewWidth, height: 250))
        titleView.backgroundColor = .white
//        titleView.layer.shadowColor = UIColor.lightGray.cgColor
//        titleView.layer.shadowOpacity = 1
//        titleView.layer.shadowOffset = CGSize.zero
//        titleView.layer.shadowRadius = 5
//        titleView.layer.shadowPath = UIBezierPath(rect: titleView.bounds).cgPath
//        titleView.layer.shouldRasterize = true
        
        let items = ["Blog", "Trade"]
        let picker = UISegmentedControl(items: items)
        picker.selectedSegmentIndex = 0
        picker.frame = CGRect(x: viewWidth/2 - 50, y: 40, width: 100, height: 25)
        picker.addTarget(self, action: #selector(selectFeedType(sender:)), for: .valueChanged)
        titleView.addSubview(picker)
        
        
        let titleField = UITextField(frame: CGRect(x: 20, y: 90, width: viewWidth - 40, height: 25))
        titleField.tag = 1
        titleField.textAlignment = .center
        titleField.placeholder = "Enter the title for the article"
        titleField.returnKeyType = .next
        titleField.delegate = self
        titleView.addSubview(titleField)
        
        let titleLine = UIView(frame: CGRect(x: 30, y: 120, width: viewWidth - 60, height: 1))
        titleLine.backgroundColor = .lightGray
        titleView.addSubview(titleLine)
        
        let nextButton = UIButton(frame: CGRect(x: viewWidth/2 - 25, y: 150, width: 50, height: 50))
        nextButton.setImage(#imageLiteral(resourceName: "Next.png"), for: .normal)
        nextButton.addTarget(self, action: #selector(goToEditor), for: .touchUpInside)
        titleView.addSubview(nextButton)
        
        self.view.addSubview(titleView)
        
        titleField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func selectFeedType(sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            feedType = "Blog"
        } else {
            feedType = "Trade"
        }
    }
    
    @objc func goToEditor(){
        if currentPageIndex == 0 {
            currentPageIndex = 1
            
            let viewWidth = screenWidth - 20
            editorView = UIView(frame: CGRect(x: 10 + screenWidth, y: 20, width: viewWidth, height: 250))
            editorView.backgroundColor = .white
            
            let editorTextView = UITextView(frame: CGRect(x: 0, y: 0, width: editorView.frame.size.width,
                                                          height: editorView.frame.size.height))
            editorTextView.keyboardType = .default
            editorTextView.layer.shadowColor = UIColor.lightGray.cgColor
            editorTextView.layer.shadowOpacity = 1
            editorTextView.layer.shadowOffset = CGSize.zero
            editorTextView.layer.shadowRadius = 5
            editorTextView.layer.shadowPath = UIBezierPath(rect: editorTextView.bounds).cgPath
            editorTextView.layer.shouldRasterize = true
            editorTextView.clipsToBounds = false
            
            editorView.addSubview(editorTextView)
            
            self.view.addSubview(editorView)
            
            
            UIView.animate(withDuration: 0.5, animations: {
                self.titleView.frame.origin.x -= screenWidth
                self.editorView.frame.origin.x -= screenWidth
            }, completion: { (_) in
                editorTextView.becomeFirstResponder()
            })
        } else {
            print("skipped")
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            print(keyboardFrame?.size.height)
            /*let heightConstraint = reportTxtView.constraints.filter { $0.identifier == "reportTxtViewHeight" }
            if let heightConstraint = heightConstraint.first {
                heightConstraint.constant = UIScreen.main.bounds.height - (keyboardFrame?.height)! - reportHeightOffset
            }*/
        }
    }
    
}

extension FeedEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToEditor()
        return true
    }
}
