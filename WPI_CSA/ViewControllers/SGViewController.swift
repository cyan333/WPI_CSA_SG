//
//  MainViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import Foundation

let padding: CGFloat = 10
let imgViewWidth: Int = 130
let screenWidth: CGFloat = UIScreen.main.bounds.width
let coverImg = "<img src=\"cover.jpg\" height=\"450\" width=\"450\"/>"

protocol MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?)
    func reopenMenu()
    func displayArticleAndSaveMenuState(article: Article?, keyword: String?, menuList: [Menu])
}

class SGImgTextCell: UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
}

class SGTextCell: UITableViewCell{
    @IBOutlet weak var textView: UITextView!
}

class SGImgCell: UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
}

class SGNavCell: UITableViewCell{
    @IBOutlet var prevBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
}

class SGViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    
    var searchKeyword: String?
    var menuList = [Menu]()
    
    var db: SGDatabase?
    var article: Article?
    
    override func viewDidLoad() {
        SGDatabase.copySgDbToDocumentFolder()
        //print("CURRENTVERSION: " + Utils.getParam(named: appVersion)!)
        /*let haha = "1.00.345"
        let ind = haha.index(haha.endIndex, offsetBy: -3)
        let subVersion = haha.substring(from: ind)
        let subVer = Int(subVersion)! - 1
        print(haha.substring(to: ind) + String(format: "%03d", subVer))*/
        //let a = "INSERT OR REPLACE INTO PARAMS VALUES ('appStatus', 'OK');"
        //let a = "INSERT OR REPLACE INTO PARAMS VALUES ('appVersion', '1.00.001');"
        //SGDatabase.run(queries: a)
        //print(SGDatabase.getParam(named: "test1"))
        //print(SGDatabase.getParam(named: "test2"))
        //let htmlStr: String = "<font size=\"6\">This is some text!</font><font size=\"16\">This</font>"
        //let attriStr: NSAttributedString? = htmlStr.htmlAttributedString()
        //print(a.htmlAttributedString()!.htmlString()!)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        DispatchQueue.global(qos: .background).async {
            self.article = Article(content: coverImg)
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: need some tweak here
            }
        }
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showToast(_:)),
                                               name: NSNotification.Name.init("showToast"), object: nil)
    }
    
    func showToast(_ notification: NSNotification) {
        if let message = notification.userInfo?["message"] as? String {
            var style = ToastStyle()
            style.messageAlignment = .center
            DispatchQueue.main.async {
                self.view.makeToast(message, duration: 3.0, position: .center, style: style)
            }
        }
        
    }
    
    func goToPreviousArticle(){
        do{
            let sgDatabase = try SGDatabase.connect()
            self.article = sgDatabase.getArticle(byMenuId: (article?.prevMenuId!)!)
        }catch {
            print(error)
        }
        
        DispatchQueue.global(qos: .background).async {
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: MAY need some tweak here
            }
        }
    }
    
    func goToNextArticle(){
        do{
            let sgDatabase = try SGDatabase.connect()
            self.article = sgDatabase.getArticle(byMenuId: (self.article?.nextMenuId!)!)
        }catch {
            print(error)
        }
        
        DispatchQueue.global(qos: .background).async {
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)//TODO: MAY need some tweak here
            }
        }
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func action(_ sender: UIButton) {
        if Utils.appMode == .Offline {
            let alert = UIAlertController(title: nil, message: "This feature won't work in offline mode. Please go to setting and check network status.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        optionMenu.addAction(UIAlertAction(title: "Report a problem", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if Utils.appMode == .Login {
                let alert = UIAlertController(title: nil, message: "No user logged in. Please login so that we can get back to you and keep track of reports.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Login & Register", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.tabBarController?.selectedIndex = 1
                }))
                alert.addAction(UIAlertAction(title: "Report anyway", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.performSegue(withIdentifier: "SGReportSegue", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "SGReportSegue", sender: nil)
            }
            
        }))
        optionMenu.addAction(UIAlertAction(title: "Create new artile", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if Utils.appMode == .Login {
                let alert = UIAlertController(title: nil, message: "No user logged in. This feature is only available after logging in", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "SGCreateArticleSegue", sender: nil)
            }
            
        }))
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func PanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MenuViewController {
            if let keyword = searchKeyword{
                destinationViewController.keyword = keyword
                destinationViewController.searchResults = menuList
            }else{
                destinationViewController.menuList = menuList
            }
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
        }else if let destinationViewController = segue.destination as? UINavigationController {
            if let reportViewController = destinationViewController.topViewController as? ReportViewController {
                if let article = article {
                    reportViewController.menuId = article.menuId
                }else{
                    reportViewController.menuId = -1
                }
            }else if let editorViewController = destinationViewController.topViewController as? EditorViewController {
                if let article = article {
                    editorViewController.menuId = article.menuId
                }else{
                    editorViewController.menuId = -1
                }
            }
            
        }
    }
    
    
}

extension SGViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let article =  article {
            return article.menuId == 0 ? article.paragraphs.count : article.paragraphs.count + 1 //Nav cell
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let article =  article {
            if indexPath.row < article.paragraphs.count {
                return article.paragraphs[indexPath.row].cellHeight
            } else {
                return 65 //Nav cell
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var paragraph = Paragraph()
        if let article =  article {
            if indexPath.row == article.paragraphs.count {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
                let attributes: [String : Any] = [NSParagraphStyleAttributeName: paragraph]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SGNavCell") as! SGNavCell
                cell.prevBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 10)
                cell.prevBtn.layer.borderWidth = 1
                cell.prevBtn.layer.cornerRadius = 5
                cell.prevBtn.layer.borderColor = self.view.tintColor.cgColor
                cell.prevBtn.titleLabel?.numberOfLines = 2
                cell.prevBtn.addTarget(self, action:#selector(goToPreviousArticle), for: .touchUpInside)
                if let prevMenuText = article.prevMenuText {
                    cell.prevBtn.setAttributedTitle(NSMutableAttributedString(string: "Previous\n" + prevMenuText, attributes: attributes), for: .normal)
                    cell.prevBtn.isEnabled = true
                    cell.prevBtn.alpha = 1
                } else {
                    cell.prevBtn.setAttributedTitle(NSMutableAttributedString(string: "Previous", attributes: attributes), for: .normal)
                    cell.prevBtn.isEnabled = false
                    cell.prevBtn.alpha = 0.5
                }
                
                cell.nextBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 15)
                cell.nextBtn.layer.borderWidth = 1
                cell.nextBtn.layer.cornerRadius = 5
                cell.nextBtn.layer.borderColor = self.view.tintColor.cgColor
                cell.nextBtn.titleLabel?.numberOfLines = 2
                cell.nextBtn.addTarget(self, action:#selector(goToNextArticle), for: .touchUpInside)
                if let nextMenuText = article.nextMenuText {
                    cell.nextBtn.setAttributedTitle(NSMutableAttributedString(string: "Next\n" + nextMenuText, attributes: attributes), for: .normal)
                    cell.nextBtn.isEnabled = true
                    cell.nextBtn.alpha = 1
                } else {
                    cell.nextBtn.setAttributedTitle(NSMutableAttributedString(string: "Next", attributes: attributes), for: .normal)
                    cell.nextBtn.isEnabled = false
                    cell.nextBtn.alpha = 0.5
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
                return cell
            }
            paragraph = article.paragraphs[indexPath.row]
        }
        
        switch paragraph.type {
        case .Plain:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
            
            if paragraph.cellHeight == 0 {
                cell.textView.attributedText = paragraph.content
                let size = cell.textView.sizeThatFits(CGSize(width: screenWidth - padding * 2,
                                                             height: .greatestFiniteMagnitude))
                paragraph.textViewHeight = size.height
                paragraph.cellHeight = size.height
            }else{
                cell.textView.attributedText = paragraph.content
            }
            
            let filteredConstraints = cell.textView.constraints.filter { $0.identifier == "textCellTextHeight" }
            if let heightConstraint = filteredConstraints.first {
                heightConstraint.constant = paragraph.textViewHeight
            }
            
            if paragraph.separatorType == .Full {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else if paragraph.separatorType == .None{
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            }
            
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgCell") as! SGImgCell
            
            if paragraph.cellHeight == 0 {
                if let imgWidth = paragraph.properties?["width"], let imgHeight = paragraph.properties?["height"] {
                    if let imgWidthInt = Int(imgWidth as! String), let imgHeightInt = Int(imgHeight as! String) {
                        paragraph.imgViewHeight = CGFloat(Int(cell.imgView.frame.size.width) * imgHeightInt / imgWidthInt)
                    }
                }
                paragraph.cellHeight = paragraph.textViewHeight > paragraph.imgViewHeight ?
                    paragraph.textViewHeight + padding * 2 :
                    paragraph.imgViewHeight + padding * 2
            }
            
            if let imgName = paragraph.properties?["src"] {
                cell.imgView.image = UIImage(named: imgName as! String)
                let filteredConstraints = cell.imgView.constraints.filter { $0.identifier == "ImgCellImgHeight" }
                if let heightConstraint = filteredConstraints.first {
                    heightConstraint.constant = paragraph.imgViewHeight
                }
            }else{
                //TODO: friendly error message?
                print("Cannot read image")
            }
            
            if(paragraph.separatorType == .Full){
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else if (paragraph.separatorType == .None){
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            }
            
            return cell
        case .ImageText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            
            if paragraph.cellHeight == 0 {
                cell.textView.attributedText = paragraph.content
                let size = cell.textView.sizeThatFits(CGSize(width: screenWidth - CGFloat(imgViewWidth) - padding * 2,
                                                             height: .greatestFiniteMagnitude))
                paragraph.textViewHeight = size.height
                if let imgWidth = paragraph.properties?["width"], let imgHeight = paragraph.properties?["height"] {
                    if let imgWidthInt = Int(imgWidth as! String), let imgHeightInt = Int(imgHeight as! String) {
                        paragraph.imgViewHeight = CGFloat(imgViewWidth * imgHeightInt / imgWidthInt)
                    }
                }
                paragraph.cellHeight = paragraph.textViewHeight > paragraph.imgViewHeight ?
                    paragraph.textViewHeight + padding * 2 :
                    paragraph.imgViewHeight + padding * 2
            }else{
                cell.textView.attributedText = paragraph.content
            }
            if let imgName = paragraph.properties?["src"] {
                cell.imgView.image = UIImage(named: imgName as! String)
                let filteredConstraints = cell.imgView.constraints.filter { $0.identifier == "imgTxtCellImgHeight" }
                if let heightConstraint = filteredConstraints.first {
                    heightConstraint.constant = paragraph.imgViewHeight
                }
            }else{
                //TODO: friendly error message?
                print("Cannot read image")
            }
            let filteredConstraints = cell.textView.constraints.filter { $0.identifier == "imgTxtCellTextHeight" }
            if let heightConstraint = filteredConstraints.first {
                heightConstraint.constant = paragraph.textViewHeight
            }
            
            if(paragraph.separatorType == .Full){
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else if (paragraph.separatorType == .None){
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            return cell
        }
    }
}

extension SGViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath)
    }
}

extension SGViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator:
        UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension SGViewController : MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?) {
        dismiss(animated: true){
            self.performSegue(withIdentifier: segueName, sender: sender)
        }
    }
    
    func reopenMenu(){
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    func displayArticleAndSaveMenuState(article: Article?, keyword: String?, menuList: [Menu]){
        self.searchKeyword = keyword
        self.menuList = menuList
        if let art = article {
            if(art.menuId != self.article?.menuId){
                DispatchQueue.global(qos: .background).async {
                    self.article = art
                    self.article?.processContent()
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: need some tweak here
                    }
                }
            }
        }
    }
}

