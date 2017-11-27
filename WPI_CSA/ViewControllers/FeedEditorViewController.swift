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
    //var editorView: UIView!
    var editorTextView: UITextView!
    var editorView: EditorView!
    
    var currentTypingAttributes: [String: Any] = [:]
    
    var currentPageIndex = 0
    var keyboardHeight: CGFloat = 0
    
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
        
        let nextButton = UIButton(frame: CGRect(x: viewWidth/2 + 25, y: 150, width: 50, height: 50))
        nextButton.setImage(#imageLiteral(resourceName: "Next.png"), for: .normal)
        nextButton.addTarget(self, action: #selector(goToEditor), for: .touchUpInside)
        titleView.addSubview(nextButton)
        
        let cancelButton = UIButton(frame: CGRect(x: viewWidth/2 - 75, y: 150, width: 50, height: 50))
        cancelButton.setImage(#imageLiteral(resourceName: "Cancel.png"), for: .normal)
        titleView.addSubview(cancelButton)
        
        self.view.addSubview(titleView)
        
        // Start setting up editor view
        editorTextView = UITextView(frame: CGRect(x: 10 + screenWidth, y: 20, width: screenWidth - 20,
                                                  height: screenHeight - keyboardHeight - 70))
        editorTextView.keyboardType = .default
        editorTextView.clipsToBounds = true
        editorTextView.layer.shadowColor = UIColor.lightGray.cgColor
        editorTextView.layer.shadowOpacity = 1
        editorTextView.layer.shadowOffset = CGSize.zero
        editorTextView.layer.shadowRadius = 5
        editorTextView.layer.shadowPath = UIBezierPath(rect: editorTextView.bounds).cgPath
        editorTextView.layer.shouldRasterize = true
        editorTextView.delegate = self
        
        self.view.addSubview(editorTextView)
        
        editorView = EditorView(frame: CGRect(x: 0, y: screenHeight - keyboardHeight, width: screenWidth, height: 44))
        editorView.delegate = self
        
        self.view.addSubview(editorView)
        
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
            
            
            
            
            UIView.animate(withDuration: 0.5, animations: {
                self.titleView.frame.origin.x -= screenWidth
                self.editorTextView.frame.origin.x -= screenWidth
                self.editorView.frame.origin.y = screenHeight - self.keyboardHeight - 44
            }, completion: { (_) in
                self.editorTextView.becomeFirstResponder()
            })
        } else {
            print("skipped")
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration = TimeInterval((userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
            let curve = UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
            let options = UIViewAnimationOptions(rawValue: curve)
            
            //print(keyboardFrame?.size.height)
            keyboardHeight = (keyboardFrame?.size.height)!
            
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.editorTextView.frame.size.height = screenHeight - self.keyboardHeight - 70
                if self.currentPageIndex == 1{
                self.editorView.frame.origin.y = screenHeight - self.keyboardHeight - 44
                }
            }, completion: { (_) in
                //
            })
        }
    }
    
}

extension FeedEditorViewController: EditorViewDelegate {
    func currentFontUpdated(to font: EditorFont) {
        
        let fontSize = CGFloat(Int(font.currentFontSize) ?? 15)
        var newFont = UIFont.systemFont(ofSize: fontSize, weight: font.bold ? UIFont.Weight.heavy : UIFont.Weight.regular)
        
        
        if font.italic {
            let fontDescriptor = newFont.fontDescriptor.withSymbolicTraits(.traitItalic)
            newFont = UIFont(descriptor: fontDescriptor!, size: 0)
        }
        
        currentTypingAttributes[NSAttributedStringKey.font.rawValue] = newFont
        
        if font.underline {
            currentTypingAttributes[NSAttributedStringKey.underlineStyle.rawValue] = NSUnderlineStyle.styleSingle.rawValue
        } else {
            currentTypingAttributes[NSAttributedStringKey.underlineStyle.rawValue] = NSUnderlineStyle.styleNone.rawValue
        }
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        switch font.currentAlignment {
        case "center":
            paragraphStyle.alignment = .center
        case "right":
            paragraphStyle.alignment = .right
        default:
            paragraphStyle.alignment = .left
        }
        currentTypingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] = paragraphStyle
        
        switch font.currentFontColor {
        case "red":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "E31B0F")
        case "blue":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "07C5F1")
        case "yellow":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "FFD64C")
        case "gray":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "808080")
        case "green":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "68A46E")
        case "pink":
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor(hexString: "FF6B89")
        default:
            currentTypingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = UIColor.black
        }
        
    }
    
    func backButtonClicked() {
        //
    }
    
    func cancelButtonClicked() {
        //
    }
    
    func submitButtonClicked() {
        //print(editorTextView.attributedText.htmlString() ?? "failed")
        let newString = editorTextView.attributedText!
        newString.enumerateAttributes(in: NSMakeRange(0, newString.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
            (object, range, stop) in
            if object.keys.contains(NSAttributedStringKey.attachment) {
                print(1)
            } else {
                print(2)
            }
        }
    }
    
    func imageButtonClicked() {
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = UIImage(named: "defaultAvatar.png")
        
        let imageString = NSAttributedString(attachment: image1Attachment)
        
        let newString = NSMutableAttributedString(attributedString: editorTextView.attributedText)
        newString.replaceCharacters(in: editorTextView.selectedRange, with: imageString)
        
        editorTextView.attributedText = newString
        
        
        
    }
    
    
}

extension FeedEditorViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        editorTextView.allowsEditingTextAttributes = true
        
        currentTypingAttributes = editorTextView.typingAttributes
        currentTypingAttributes[NSAttributedStringKey.font.rawValue] = UIFont.systemFont(ofSize: 15)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.typingAttributes = currentTypingAttributes
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        editorTextView.typingAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.blue, NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 17)]
    }
}

extension FeedEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToEditor()
        return true
    }
}
