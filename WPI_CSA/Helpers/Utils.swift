//
//  Utils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/17/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit


//Format: AppMajorVerion.AppSubVersion.ContentVersion
//Update this number results server version update
let baseVersion = "1.03.001"

//All application parameters are declared here
let appVersion = "appVersion"
let appStatus = "appStatus"
let reportEmail = "email"
let savedUsername = "username"
let savedPassword = "password"
let localTitle = "title"
let localArticle = "article"
let localArticleType = "articleType"
let localArticleCover = "articleCover"

//View tag numbers
let statusBackgroundViewTag = 50 // Used to change status bar color
let sgTableBackgroundViewTag = 51// Used for the half colored background view


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
                versionToCheck = baseVersion
                Utils.initializeApp()
            } else if versionArr[1] != baseVersion.components(separatedBy: ".")[1]{ //Software version mismatch
                versionToCheck = baseVersion
                Utils.initializeApp()// TODO: merge top if nothing special
            }
        }else{//First time install
            Utils.initializeApp()
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
                Database.run(queries: updates)
                dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
            } else if status == "BM" {
                if updates != "" {
                    Database.run(queries: updates)
                }
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let ind = version.index(version.endIndex, offsetBy: -3)
                    if let prevVersion = Int(String(version[ind...])) {
                        let prevVersionStr = String(version[..<ind]) + String(format: "%03d", prevVersion - 1)
                        Utils.setParam(named: appVersion, withValue: prevVersionStr)
                    }else{
                        Utils.setParam(named: appVersion, withValue: version)//TODO: Do something here
                    }
                }))
                alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Utils.setParam(named: appVersion, withValue: version)
                }))
                hideIndicator()
                vc.present(alert, animated: true, completion: nil)
                
                dismissIndicatorAndTryLogin(vc: vc, showAlert: showAlert)
            } else if status == "AU" {
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Never show this again", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Utils.setParam(named: appStatus, withValue: "")
                }))
                hideIndicator()
                vc.present(alert, animated: true, completion: nil)
                //Do not login user because http request updates may break login process
            } else {
                hideIndicator()
                process(errorMessage: status, onViewController: vc, showingServerdownAlert: showAlert)
            }
            
        })
        
    }
    
    open class func initializeApp() {
        Utils.setParam(named: appStatus, withValue: "OK")
        Utils.setParam(named: appVersion, withValue: baseVersion)
        CacheManager.localDirInitiateSetup()
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
                        hideIndicator()
                        NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"),
                                                        object: nil)
                    }else{
                        hideIndicator()
                        process(errorMessage: error,
                                onViewController: vc,
                                showingServerdownAlert: showAlert)
                    }
                })
            }else{
                hideIndicator()
                NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
            }
        }else{
            hideIndicator()
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
                show(alertMessage: "The server is down. Please email admin@fmning.com for help", onViewController: vc)
            }else{
                print("server down but not showin")
            }
        }else{
            show(alertMessage: errorMsg, onViewController: vc)
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
    
    open class func hideIndicator(){
        OperationQueue.main.addOperation{
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    open class func isEmailAddress(email: String) -> Bool {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    open class func checkPasswordStrength(password: String) -> String{
        if password.count < 6 {
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

@IBDesignable extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension String {
    func htmlAttributedString(ratio: FontRatio) -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [.documentType : NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }
        html.beginEditing()
        html.enumerateAttributes(in: NSMakeRange(0, html.length), options: .init(rawValue: 0)) {
            (value, range, stop) in
            
            if let font = value[NSAttributedStringKey.font] as? UIFont {
                
                let fontRatio: CGFloat = ratio == .Normal ? 0.75 : 1.25
                //print(font.fontName)
                let size = font.pointSize * fontRatio
                var finalFont = UIFont.systemFont(ofSize: size)
                
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                    && font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    finalFont = UIFont(descriptor: finalFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])!, size: size)
                } else if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    finalFont = UIFont(descriptor: finalFont.fontDescriptor
                        .withSymbolicTraits(.traitItalic)!, size: size)
                } else if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    finalFont = UIFont(descriptor: finalFont.fontDescriptor
                        .withSymbolicTraits(.traitBold)!, size: size)
                }
                
                
                html.addAttribute(NSAttributedStringKey.font,
                                  value: finalFont,
                                  range: range)
            }
        }
        html.endEditing()
        return html
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    
    func getHtmlAttributes() -> [String: Any] {
        var dic = [String: Any]()
        let regex = try! NSRegularExpression(pattern: "[^ ]*[ ]*=[ ]*\".*?\"")
        let matchs = regex.matches(in: self, range: NSRange(location: 0, length: self.count)).map{(self as NSString).substring(with: $0.range)}
        
        for i in 0 ..< matchs.count {
            let index = matchs[i].range(of: "=")
            let key = String(matchs[i][..<index!.lowerBound]).trim()
            //TODO: Can there be double quote in value? Or that is \\" so won't be affected? Which means we need to replace that with \" ?
            let value = String(matchs[i][index!.upperBound...]).replacingOccurrences(of: "\"", with: "").trim()
            dic[key] = value
        }
        
        return dic
    }
    
    
    var Iso8601DateUTC: Date {
        if let date = Formatter.iso8601FullUTC.date(from: self){
            return date
        } else if let date = Formatter.iso8601AbbrUTC.date(from: self){
            return date
        } else {
            return Formatter.iso8601AbbrUTC.date(from: "1970-01-01T00:00:00Z")!
        }
    }
}

extension Int {
    func toWCImageId() -> String {
        return "WCImage_\(self)"
    }
}

extension NSAttributedString {
    func htmlString() -> String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
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

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIViewController {
    func addOrUpdateStatusBGView(viewController: UIViewController, color: UIColor) -> Void {
        var view = viewController.view.viewWithTag(statusBackgroundViewTag)
        if view == nil {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size:CGSize(width: UIScreen.main.bounds.size.width, height:20))
            view = UIView.init(frame: rect)
            view?.tag = statusBackgroundViewTag
            viewController.view?.addSubview(view!)
        }
        view?.backgroundColor = color
        
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func compressRateForSize(target: Int) -> CGFloat {
        let data = NSData(data: UIImageJPEGRepresentation(self, 1)!)
        let fullSize = data.length / 1024
        let rate = fullSize / target
        if rate == 0 {
            return 1
        } else if rate <= 2 {
            return 0.75
        } else if rate <= 4 {
            return 0.5
        } else if rate <= 8 {
            return 0.25
        } else {
            return 0
        }
    }
}

extension Formatter {
    /**
     UTC Time formatter that converts iso-8601 with millisecond.
     Mainly used to convert full iso-8601 time string from server to swift date in UTC timezone
     Examples:
     "2017-01-09T17:34:12.215Z".Iso8601DateUTC returns UTC Date 2017-01-09 17:34:12
     Formatter.iso8601FullUTC.string(from: AboveDate) returns 2017-01-09T12:34:12.215-05:00
     */
    static let iso8601FullUTC: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
        
    }()
    
    /**
     UTC Time formatter that converts iso-8601 without millisecond.
     Mainly used to convert abbreviated iso-8601 time string from server to swift date in UTC timezone
     Examples:
     "2017-01-09T17:34:12Z".Iso8601DateUTC returns UTC Date 2017-01-09 17:34:12
     Formatter.iso8601AbbrUTC.string(from: AboveDate) returns 2017-01-09T17:34:12Z
     */
    static let iso8601AbbrUTC: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    /**
     Formatter with local time zone that converts simplified date
     Mainly used to convert UTC Date object to local time string and display on UI, vice versa
     This local time zone will handle all timezone changes.
     Examples:
     
     EDT: Adding offsets for GMT-4 between Mar to Nov
     Formatter.abbrLocalZone.date(from: "2006/05/01 10:41:00") returns 2006-05-01 14:41:00 UTC
     Formatter.abbrLocalZone.string(from: AboveDate) returns 2006/05/01 10:41:00
     
     EST: Adding offsets for GMT-5 between Nov to Mar
     Formatter.abbrLocalZone.date(from: "2006/12/01 10:41:00") returns 2006-12-01 15:41:00 UTC
     Formatter.abbrLocalZone.string(from: AboveDate) returns 2006/05/01 10:41:00
     */
    static let abbrLocalZone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601AbbrUTC.string(from: self)
    }
    
    var toString: String {
        return Formatter.abbrLocalZone.string(from: self)
    }
}

extension FileManager {
    
    func fileSizeAtPath(path: String) -> Int64 {
        do {
            let fileAttributes = try attributesOfItem(atPath: path)
            let fileSizeNumber = fileAttributes[FileAttributeKey.size] as? NSNumber
            let fileSize = fileSizeNumber?.int64Value
            return fileSize!
        } catch {
            print("error reading filesize, NSFileManager extension fileSizeAtPath")
            return 0
        }
    }
    
    func folderSizeAtPath(path: String) -> Int64 {
        var size : Int64 = 0
        do {
            let files = try subpathsOfDirectory(atPath: path)
            for i in 0 ..< files.count {
                size += fileSizeAtPath(path:path.appending("/"+files[i]))
            }
        } catch {
            print("error reading directory, NSFileManager extension folderSizeAtPath")
        }
        return size
    }
    
    func format(size: Int64) -> String {
        let folderSizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.file)
        return folderSizeStr
    }
    
}
