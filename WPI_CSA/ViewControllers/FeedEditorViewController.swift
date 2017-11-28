//
//  FeedEditorViewController.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/12/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class FeedEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var feedType = "Blog"
    var titleView: UIView!
    var titleField: UITextField!
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
        
        let items = ["Blog", "Trade"]
        let picker = UISegmentedControl(items: items)
        picker.selectedSegmentIndex = 0
        picker.frame = CGRect(x: viewWidth/2 - 50, y: 40, width: 100, height: 25)
        picker.addTarget(self, action: #selector(selectFeedType(sender:)), for: .valueChanged)
        titleView.addSubview(picker)
        
        
        titleField = UITextField(frame: CGRect(x: 20, y: 90, width: viewWidth - 40, height: 25))
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
        cancelButton.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        titleView.addSubview(cancelButton)
        
        self.view.addSubview(titleView)
        
        // Start setting up editor view
        editorTextView = UITextView(frame: CGRect(x: 10 + screenWidth, y: 20, width: screenWidth - 20,
                                                  height: screenHeight - keyboardHeight - 70))
        editorTextView.keyboardType = .default
        editorTextView.clipsToBounds = true
//        editorTextView.layer.shadowColor = UIColor.lightGray.cgColor
//        editorTextView.layer.shadowOpacity = 1
//        editorTextView.layer.shadowOffset = CGSize.zero
//        editorTextView.layer.shadowRadius = 5
//        editorTextView.layer.shadowPath = UIBezierPath(rect: editorTextView.bounds).cgPath
//        editorTextView.layer.shouldRasterize = true
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
    
    @objc func cancelClicked() {
        
        if titleField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" ||
            editorTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            let confirm = UIAlertController(title: nil, message: "Are you sure you want to cancel?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Yes, discard article", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Utils.setParam(named: localTitle, withValue: "")
                Utils.setParam(named: localArticle, withValue: "")
                self.dismiss(animated: true, completion: nil)
            }))
            confirm.addAction(UIAlertAction(title: "Yes, save article locally", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Utils.setParam(named: localTitle, withValue: self.titleField.text!)
                Utils.setParam(named: localArticle, withValue: self.getEditorHtmlText())
                self.dismiss(animated: true, completion: nil)
            }))
            confirm.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(confirm, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getEditorHtmlText() -> String {
        
        var resultText = ""
        var index = 0
        
        if let htmlText = editorTextView.attributedText.htmlString() {
            resultText = htmlText
            let newString = editorTextView.attributedText!
            newString.enumerateAttributes(in: NSMakeRange(0, newString.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
                (object, range, stop) in
                if object.keys.contains(NSAttributedStringKey.attachment) {
                    if let attachment = object[NSAttributedStringKey.attachment] as? NSTextAttachment {
                        if let image = attachment.image {
                            let compressionRate = image.compressRateForSize(target: 250)
                            let imgString = UIImageJPEGRepresentation(image, compressionRate)?.base64EncodedString()//.base64EncodedString(options: NSData.Base64DecodingOptions.)
                            
                            let imgNameExt = index == 0 ? "" : "_\(index)"
                            
                            index += 1
                            guard let range = resultText
                                .range(of: "<img src=\"file:///Attachment\(imgNameExt).png\" alt=\"Attachment\(imgNameExt).png\">") else {
                                return
                            }
                            
                            resultText = resultText.replacingCharacters(in: range, with: "<img src=\"data:image/jpeg;base64,\(imgString!)\">")
                        }
                    }
                }
            }
        }
        return resultText
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let attachmentWidth = screenWidth - 40
            let attachment = NSTextAttachment()
            attachment.image = chosenImage
            attachment.bounds = CGRect(x: 0, y: 0, width: attachmentWidth,
                                       height: chosenImage.size.height * attachmentWidth / chosenImage.size.width)
            
            let imageString = NSAttributedString(attachment: attachment)
            let newString = NSMutableAttributedString(attributedString: editorTextView.attributedText)
            newString.replaceCharacters(in: editorTextView.selectedRange, with: imageString)
            editorTextView.attributedText = newString
        }
        
        self.dismiss(animated: true) {
            self.editorTextView.becomeFirstResponder()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            self.editorTextView.becomeFirstResponder()
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
        currentPageIndex = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.titleView.frame.origin.x += screenWidth
            self.editorTextView.frame.origin.x += screenWidth
            self.editorView.frame.origin.y = screenHeight - self.keyboardHeight
        }, completion: { (_) in
            self.titleField.becomeFirstResponder()
        })
    }
    
    func cancelButtonClicked() {
        cancelClicked()
    }
    
    func submitButtonClicked() {
        print(getEditorHtmlText())
    }
    
    func imageButtonClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            Utils.show(alertMessage: "Can not add image. Photo album not available", onViewController: self)
        }
        
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
