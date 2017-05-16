//
//  MainViewController.swift
//  WPI SG
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

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

class SGViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    
    var searchKeyword: String?
    var menuList = [Menu]()
    
    var db: SGDatabase?
    var article: Article?
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        DispatchQueue.global(qos: .background).async {
            self.article = Article(content: coverImg)
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: need some tweak here
            }
            
        }
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
                self.present(alert, animated: true, completion: nil)
            }else if status == "Ok"{
                if let password = SGDatabase.getParam(named: "password"),
                    let username = SGDatabase.getParam(named: "username"){
                    if password != "" && username != ""{
                        WCUserManager.loginUser(withUsername: username,
                                                andPassword: password,
                                                completion: { (error, user) in
                                                    if error == "" {
                                                        WCService.currentUser = user
                                                        NotificationCenter.default.post(name: NSNotification.Name.init("reloadUserCell"), object: nil)
                                                    }
                        })
                    }
                }
            }else{
                print(status + title + msg)
            }
        })
        
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func action(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report a problem", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if WCService.currentUser == nil {
                let alert = UIAlertController(title: nil, message: "No user logged in. Please login so that we can get back to you and keep track of reports.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Login & Register", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.tabBarController?.selectedIndex = 1
                    
                }))
                alert.addAction(UIAlertAction(title: "Report anonymously", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.performSegue(withIdentifier: "SGReportSegue", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "SGReportSegue", sender: nil)
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
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
            }
            
        }
    }
    
    
}

extension SGViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let notNullArticle =  article {
            return notNullArticle.paragraphs.count
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let notNullArticle =  article {
            return notNullArticle.paragraphs[indexPath.row].cellHeight
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var paragraph = Paragraph()
        if let notNullArticle =  article {
            paragraph = notNullArticle.paragraphs[indexPath.row]
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
            
            if(paragraph.separatorType == .Full){
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else if (paragraph.separatorType == .None){
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
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
