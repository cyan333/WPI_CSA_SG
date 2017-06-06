//
//  Utils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/17/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

open class Utils {
    static var appMode: AppMode = .Offline
    
    open class func checkVerisonInfoAndLoginUser(onViewController vc: UIViewController, showingServerdownAlert showAlert: Bool) {
        if showAlert {//Manully click the login button
            showLoadingIndicator()
        } else {//Automatically called when app starts
            if let appStatus = SGDatabase.getParam(named: "appStatus"){
                if appStatus != "OK"{
                    return
                }
            }
        }
        if let version = SGDatabase.getParam(named: "appVersion") {
            if version == "" {
                dismissIndicator()
                return
            }else{
                WCService.checkSoftwareVersion(version: SGDatabase.getParam(named: "appVersion")!,
                                               completion: { (status, title, msg, updates, version) in
                    appMode = .Login
                    if status == "OK"{
                        dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
                    } else if status == "CU" {
                        SGDatabase.setParam(named: "appVersion", withValue: version)
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
                                SGDatabase.setParam(named: "appVersion", withValue: prevVersionStr)
                            }else{
                                SGDatabase.setParam(named: "appVersion", withValue: version)//TODO: Do something here
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                            (alert: UIAlertAction!) -> Void in
                            SGDatabase.setParam(named: "appVersion", withValue: version)
                        }))
                        dismissIndicator()
                        vc.present(alert, animated: true, completion: nil)
                        print("haha")
                        dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
                    } else if status == "AU" {
                        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                            (alert: UIAlertAction!) -> Void in
                            SGDatabase.setParam(named: "appStatus", withValue: "")
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
        }else{
            dismissIndicator()
        }
        
    }
    
    open class func dismissIndicatorAndTryLogin(vc: UIViewController, showAlert: Bool){
        if let password = SGDatabase.getParam(named: "password"),
            let username = SGDatabase.getParam(named: "username"){
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
    
}

enum AppMode{
    case Offline
    case Login
    case LoggedOn
}
