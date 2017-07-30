//
//  Utils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/17/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

let baseVersion = "1.01.001"

//All application parameters are declared here
let appVersion = "appVersion"
let appStatus = "appStatus"
let reportEmail = "email"
let savedUsername = "username"
let savedPassword = "password"
let localTitle = "title"
let localArticle = "article"

open class Utils {
    static var appMode: AppMode = .Offline
    static var menuOrderList: [Int] = []
    
    open class func checkVerisonInfoAndLoginUser(onViewController vc: UIViewController, showingServerdownAlert showAlert: Bool) {
        if showAlert {//Manully click the login button
            showLoadingIndicator()
        }
        
        //if let
        
        var versionToCheck = baseVersion
        
        if let version = Utils.getParam(named: appVersion) {
            versionToCheck = version
            let versionArr = version.components(separatedBy: ".")
            if versionArr.count != 3 {                                              //Corrupted data
                Utils.initiateApp()
            } else if versionArr[1] != baseVersion.components(separatedBy: ".")[1]{ //Software version mismatch
                Utils.initiateApp()// TODO: merge top if nothing special
            }
        }else{//First time install
            Utils.initiateApp()
        }
        
        guard let status = Utils.getParam(named: appStatus), status == "OK" else {
            return //TODO: Any friendly message?
        }
        
        WCService.checkSoftwareVersion(version: versionToCheck,
           completion: { (status, title, msg, updates, version) in
            appMode = .Login
            if status == "OK"{
                dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
            } else if status == "CU" {
                Utils.setParam(named: appVersion, withValue: version)
                SGDatabase.run(queries: updates)
                dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
            } else if status == "BM" {
                if updates != "" {
                    SGDatabase.run(queries: updates)
                }
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let ind = version.index(version.endIndex, offsetBy: -3)
                    if let prevVersion = Int(version.substring(from: ind)) {
                        let prevVersionStr = version.substring(to: ind) + String(format: "%03d", prevVersion - 1)
                        Utils.setParam(named: appVersion, withValue: prevVersionStr)
                    }else{
                        Utils.setParam(named: appVersion, withValue: version)//TODO: Do something here
                    }
                }))
                alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Utils.setParam(named: appVersion, withValue: version)
                }))
                dismissIndicator()
                vc.present(alert, animated: true, completion: nil)
                
                dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
            } else if status == "AU" {
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Utils.setParam(named: appStatus, withValue: "")
                }))
                dismissIndicator()
                vc.present(alert, animated: true, completion: nil)
                //Do not login user because http request updates may break login process
            } else {
                dismissIndicator()
                process(errorMessage: status, onViewController: vc, showingServerdownAlert: showAlert)
            }
            
        })
        
    }
    
    open class func initiateApp() {
        Utils.setParam(named: appStatus, withValue: "OK")
        Utils.setParam(named: appVersion, withValue: baseVersion)
        SGDatabase.copySgDbToDocumentFolder()
    }
    
    open class func dismissIndicatorAndTryLogin(vc: UIViewController, showAlert: Bool){
        if let password = Utils.getParam(named: savedPassword),
            let username = Utils.getParam(named: savedUsername){
            if password != "" && username != ""{
                WCUserManager.loginUser(withUsername: username, andPassword: password, completion: {
                    (error, user) in
                    if error == "" {
                        appMode = .LoggedOn
                        WCService.currentUser = user
                        dismissIndicator()
                        NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"),
                                                        object: nil)
                    }else{
                        dismissIndicator()
                        process(errorMessage: error,
                                onViewController: vc,
                                showingServerdownAlert: showAlert)
                    }
                })
            }else{
                dismissIndicator()
                NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
            }
        }else{
            dismissIndicator()
            NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
        }
    }
    
    open class func process(errorMessage errorMsg: String, onViewController vc: UIViewController,
                            showingServerdownAlert showAlert: Bool) {
        if errorMsg == serverDown {
            WCService.currentUser = nil
            appMode = .Offline
            NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
            if showAlert {
                OperationQueue.main.addOperation{
                    let alert = UIAlertController(title: "Something goes wrong",
                                                  message: "The server is down. Please email admin@fmning.com for help",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    vc.present(alert, animated: true, completion: nil)
                }
            }else{
                print("server down but not showin")
            }
        }else{
            OperationQueue.main.addOperation{
                let alert = UIAlertController(title: "Something goes wrong", message: errorMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    open class func show(alertMessage alert: String, onViewController vc: UIViewController) {
        OperationQueue.main.addOperation{
            let alert = UIAlertController(title: nil, message: alert, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    open class func showLoadingIndicator(){
        OperationQueue.main.addOperation{
            NVActivityIndicatorPresenter.sharedInstance.startAnimating()
        }
    }
    
    open class func dismissIndicator(){
        OperationQueue.main.addOperation{
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    open class func isEmailAddress(email: String) -> Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    open class func checkPasswordStrength(password: String) -> String{
        if password.characters.count < 6 {
            return "Password must contain at least 6 chars"
        } else {
            let letters = NSCharacterSet.letters
            let range = password.rangeOfCharacter(from: letters)
            if range != nil {
                let ints = NSCharacterSet.decimalDigits
                let intRange = password.rangeOfCharacter(from: ints)
                if intRange != nil {
                    return ""
                } else {
                    return "Password must have at least 1 number"
                }
            } else {
                return "Password must have at least 1 letter"
            }
        }
    }
    
    open class func getParam(named key: String) ->String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    open class func setParam(named key:String, withValue value:String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    open class func deleteParam(named key:String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}

enum AppMode{
    case Offline
    case Login
    case LoggedOn
}

enum FontRatio{
    case Normal
    case Enlarged
}

extension String {
    func htmlAttributedString(ratio: FontRatio) -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil) else { return nil }
        html.beginEditing()
        html.enumerateAttribute(NSFontAttributeName, in: NSMakeRange(0, html.length), options: .init(rawValue: 0)) {
            (value, range, stop) in
            if let font = value as? UIFont {
                let fontRatio: CGFloat = ratio == .Normal ? 0.75 : 1.25
                let resizedFont = font.withSize(font.pointSize * fontRatio)
                html.addAttribute(NSFontAttributeName,
                                         value: resizedFont,
                                         range: range)
            }
        }
        html.endEditing()
        return html
    }
}

extension NSAttributedString {
    func htmlString() -> String? {
        let documentAttributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes:documentAttributes)
            if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
                return htmlString
            }
        }
        catch {}
        return nil
    }
}
