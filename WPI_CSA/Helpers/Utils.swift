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
        var versionToCheck = softwareVersion
        if let version = SGDatabase.getParam(named: "suppressedVersion"){
            versionToCheck = version
        }
        WCService.checkSoftwareVersion(version: versionToCheck, completion: { (status, title, msg, version) in
            if status == "AppUpdate" {
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    SGDatabase.setParam(named: "suppressedVersion", withValue: version)
                }))
                vc.present(alert, animated: true, completion: nil)
            }else if status == "Ok"{
                appMode = .Login
                if let password = SGDatabase.getParam(named: "password"),
                    let username = SGDatabase.getParam(named: "username"){
                    if password != "" && username != ""{
                        WCUserManager.loginUser(withUsername: username,
                                                andPassword: password,
                                                completion: { (error, user) in
                                                    if error == "" {
                                                        appMode = .LoggedOn
                                                        WCService.currentUser = user
                                                        NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                                    }else{
                                                        process(errorMessage: error,
                                                                onViewController: vc,
                                                                showingServerdownAlert: showAlert)
                                                    }
                        })
                    }
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                }
            }else {
                process(errorMessage: status, onViewController: vc, showingServerdownAlert: showAlert)
            }
        })
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
        let alert = UIAlertController(title: nil, message: alert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    open class func isEmailAddress(email: String) -> Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
}

enum AppMode{
    case Offline
    case Login
    case LoggedOn
}
