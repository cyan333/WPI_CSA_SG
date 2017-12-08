//
//  FeedEditorViewController.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 11/12/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class FeedEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var articleType = "Blog"
    var coverImageView: UIImageView!
    var titleView: UIView!
    var titleField: UITextField!
    
    var editorTextView: UITextView!
    var editorView: EditorView!
    
    var currentTypingAttributes: [String: Any] = [:]
    
    var currentPageIndex = 0
    var keyboardHeight: CGFloat = 0
    
    var addingCoverImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = screenWidth - 40
        
        titleView = UIView(frame: CGRect(x: 20, y: 50, width: viewWidth, height: 250))
        titleView.backgroundColor = .white
        
        coverImageView = UIImageView(frame: CGRect(x: viewWidth/2 - 120, y: 40, width: 240, height: 150))
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = coverImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coverImageView.addSubview(blurEffectView)
        titleView.addSubview(coverImageView)
        
        let items = ["Blog", "Trade"]
        let picker = UISegmentedControl(items: items)
        picker.selectedSegmentIndex = 0
        picker.frame = CGRect(x: viewWidth/2 - 50, y: 10, width: 100, height: 25)
        picker.addTarget(self, action: #selector(selectFeedType(sender:)), for: .valueChanged)
        titleView.addSubview(picker)
        
        let coverButton = UIButton(type: .system)
        coverButton.frame = CGRect(x: viewWidth/2 - 70, y: 100, width: 140, height: 20)
        coverButton.setTitle("Add cover image", for: .normal)
        coverButton.titleLabel?.font =  UIFont.systemFont(ofSize: 13)
        coverButton.addTarget(self, action: #selector(selectCoverImage), for: .touchUpInside)
        titleView.addSubview(coverButton)
        
        titleField = UITextField(frame: CGRect(x: 20, y: 150, width: viewWidth - 40, height: 25))
        titleField.tag = 1
        titleField.textAlignment = .center
        titleField.placeholder = "Enter the title for the article"
        titleField.returnKeyType = .next
        titleField.delegate = self
        titleView.addSubview(titleField)
        
        let titleLine = UIView(frame: CGRect(x: 30, y: 180, width: viewWidth - 60, height: 1))
        titleLine.backgroundColor = .lightGray
        titleView.addSubview(titleLine)
        
        let nextButton = UIButton(frame: CGRect(x: viewWidth/2 + 25, y: 200, width: 50, height: 50))
        nextButton.setImage(#imageLiteral(resourceName: "Next.png"), for: .normal)
        nextButton.addTarget(self, action: #selector(goToEditor), for: .touchUpInside)
        titleView.addSubview(nextButton)
        
        let cancelButton = UIButton(frame: CGRect(x: viewWidth/2 - 75, y: 200, width: 50, height: 50))
        cancelButton.setImage(#imageLiteral(resourceName: "Cancel.png"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        titleView.addSubview(cancelButton)
        
        self.view.addSubview(titleView)
        
        // Start setting up editor view
        editorTextView = UITextView(frame: CGRect(x: 10 + screenWidth, y: 20, width: screenWidth - 20,
                                                  height: screenHeight - keyboardHeight - 70))
        editorTextView.keyboardType = .default
        editorTextView.clipsToBounds = true
        editorTextView.delegate = self
        
        self.view.addSubview(editorTextView)
        
        editorView = EditorView(frame: CGRect(x: 0, y: screenHeight - keyboardHeight, width: screenWidth, height: 44))
        editorView.delegate = self
        
        self.view.addSubview(editorView)
        
        if let savedArticleType = Utils.getParam(named: localArticleType), savedArticleType.trim() != "" {
            if savedArticleType == "Trade" {
                picker.selectedSegmentIndex = 1
            }
        }
        
        if let savedArticleCover = Utils.getParam(named: localArticleCover), savedArticleCover.trim() != "" {
            let imageData = Data(base64Encoded: savedArticleCover, options: [])
            if let imageData = imageData {
                let image = UIImage(data: imageData)
                coverImageView.image = image
            }
        }
        
        if let savedTitle = Utils.getParam(named: localTitle), savedTitle.trim() != "" {
            titleField.text = savedTitle
        }
        
        DispatchQueue.global(qos: .background).async {
            //TODO: This is a trick since .SFUIText bold font is not recognized
            let savedArticle = Utils.getParam(named: localArticle)?.replacingOccurrences(of: ".SFUIText", with: "Helvetica")
            //print(savedArticle!)
            var savedAttributedArticle :NSMutableAttributedString? = nil
            if savedArticle != nil && savedArticle!.trim() != "" {
                
                //editorTextView.attributedText = savedArticle.htmlAttributedString(ratio: .Enlarged)
                let regex = try! NSRegularExpression(pattern:
                    "<img.*?>")
                let matchs = regex.matches(in: savedArticle!, range: NSRange(location: 0, length: savedArticle!.count))
                    .map{(savedArticle! as NSString).substring(with: $0.range)}
                let count = matchs.count
                var imageList = [UIImage]()
                
                for i in 0 ..< count {
                    let imgAttributes = matchs[i].getHtmlAttributes()
                    if let base64 = imgAttributes["src"] as? String {
                        let imageData = Data(base64Encoded: String(base64.split(separator: ",")[1]), options: [])
                        let image = UIImage(data: imageData!)
                        
                        imageList.append(image!)
                    }
                }
                savedAttributedArticle = NSMutableAttributedString(string: "")
                savedAttributedArticle?.append(savedArticle!.htmlAttributedString(ratio: .Normal)!);
                savedAttributedArticle?.beginEditing()
                
                var currentIndex = 0
                savedAttributedArticle?.enumerateAttributes(in: NSMakeRange(0, (savedAttributedArticle?.length)!), options: .init(rawValue: 0)) {
                    (value, range, stop) in
                    
                    if let attachment = value[NSAttributedStringKey.attachment] as? NSTextAttachment {
                        let currentImage = imageList[currentIndex]
                        let attachmentWidth = screenWidth - 40
                        
                        attachment.image = currentImage
                        attachment.bounds = CGRect(x: 0, y: 0, width: attachmentWidth,
                                                   height: currentImage.size.height * attachmentWidth / currentImage.size.width)
                        currentIndex += 1
                        
                    }
                }
                savedAttributedArticle!.endEditing()
                
            }
            
            
            
            DispatchQueue.main.async {
                if savedAttributedArticle != nil {
                    self.editorTextView.attributedText = savedAttributedArticle
                }
            }
        }
        
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
            articleType = "Blog"
        } else {
            articleType = "Trade"
        }
    }
    
    @objc func selectCoverImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            addingCoverImage = true
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            Utils.show(alertMessage: "Can not add image. Photo album not available", onViewController: self)
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
            
            UIView.animate(withDuration: duration, animations: {
                self.titleView.frame.origin.y = (screenHeight - self.keyboardHeight - 250) / 2
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
                Utils.setParam(named: localArticleCover, withValue: "")
                Utils.setParam(named: localArticleType, withValue: "")
                self.dismiss(animated: true, completion: nil)
            }))
            confirm.addAction(UIAlertAction(title: "Yes, save article locally", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Utils.setParam(named: localTitle, withValue: self.titleField.text!)
                Utils.setParam(named: localArticle, withValue: self.getEditorHtmlText())
                if let image = self.coverImageView.image {
                    let compressionRate = image.compressRateForSize(target: 250)
                    let imgString = UIImageJPEGRepresentation(image, compressionRate)?.base64EncodedString()
                    if let imgString = imgString {
                        Utils.setParam(named: localArticleCover, withValue: imgString)
                    }
                }
                Utils.setParam(named: localArticleType, withValue: self.articleType)
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
                        
                        let attachmentWidth = screenWidth - 40
                        let attachmentHeight = image.size.height * attachmentWidth / image.size.width
                        
                        let imgWidth = Int(attachmentWidth)
                        let imgHeight = Int(attachmentHeight)
                        resultText = resultText.replacingCharacters(in: range,
                                                                    with: "<img src=\"data:image/jpeg;base64,\(imgString!)\" width=\"\(imgWidth)\" height=\"\(imgHeight)\" >")
                    }
                }
            }
        }
        return resultText
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if addingCoverImage {
                coverImageView.image = chosenImage
            } else {
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
            
        }
        
        self.dismiss(animated: true) {
            if self.addingCoverImage {
                self.titleField.becomeFirstResponder()
                self.addingCoverImage = false
            } else {
                self.editorTextView.becomeFirstResponder()
            }
            
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
        var newFont = UIFont.systemFont(ofSize: fontSize)
        
        
        if font.italic && font.bold {
            let fontDescriptor = newFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])
            newFont = UIFont(descriptor: fontDescriptor!, size: fontSize)
        } else if font.italic {
            let fontDescriptor = newFont.fontDescriptor.withSymbolicTraits(.traitItalic)
            newFont = UIFont(descriptor: fontDescriptor!, size: fontSize)
        } else if font.bold {
            let fontDescriptor = newFont.fontDescriptor.withSymbolicTraits(.traitBold)
            newFont = UIFont(descriptor: fontDescriptor!, size: fontSize)
        } else {
            
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
        let a = getEditorHtmlText().components(separatedBy: CharacterSet.newlines).joined(separator: "")
        print(a)
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
    
}

extension FeedEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToEditor()
        return true
    }
}
