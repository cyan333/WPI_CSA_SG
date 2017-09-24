//
//  MainViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import Foundation

var tableTopInset: CGFloat = 64


//let coverImg = "<img src=\"cover.jpg\" height=\"1836\" width=\"1200\"/>"

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
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    var coverPage: UIImageView?
    
    var searchKeyword: String?
    var menuList = [Menu]()
    
    var db: Database?
    var article: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        addOrUpdateStatusBGView(viewController: self, color: .clear)
        
        coverPage = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49))
        coverPage?.image = UIImage(named: "cover.jpg")
        coverPage?.isUserInteractionEnabled = true
        let viewBtn = UIButton(frame: CGRect(x: screenWidth/2 - 70, y: screenHeight/2,
                                                  width: 140, height: 40))
        viewBtn.setTitle("Look inside", for: .normal)
        viewBtn.titleLabel?.font = UIFont(name: "Helvetica", size: 24)
        viewBtn.setTitleColor(.white, for: .normal)
        viewBtn.setTitleColor(UIColor(hexString: "999999"), for: .highlighted)
        viewBtn.layer.borderWidth = 2
        viewBtn.layer.cornerRadius = 10
        viewBtn.layer.borderColor = UIColor.white.cgColor
        viewBtn.addTarget(self, action:#selector(lookInside), for: .touchUpInside)
        coverPage?.addSubview(viewBtn)
        self.view.addSubview(coverPage!)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showToast(_:)),
                                               name: NSNotification.Name.init("showToastOnSG"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIApplication.shared.statusBarStyle = .lightContent
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
    
    func lookInside() {
        do{
            let database = try Database.connect()
            Utils.menuOrderList = []
            menuList = database.getSubMenus(by: 0, withPrefix: "")
            
            self.article = database.getArticle(byMenuId: 1)
            
        }catch {
            print(error)
        }
        
        DispatchQueue.global(qos: .background).async {
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)//TODO: MAY need some tweak here
                self.updatePageTheme()
            }
        }
    }
    
    func goToPreviousArticle() {
        do{
            let database = try Database.connect()
            self.article = database.getArticle(byMenuId: (article?.prevMenuId!)!)
        }catch {
            print(error)
        }
        
        DispatchQueue.global(qos: .background).async {
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: MAY need some tweak here
                self.updatePageTheme()
            }
        }
    }
    
    func goToNextArticle() {
        do{
            let database = try Database.connect()
            self.article = database.getArticle(byMenuId: (self.article?.nextMenuId!)!)
        }catch {
            print(error)
        }
        
        DispatchQueue.global(qos: .background).async {
            self.article?.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)//TODO: MAY need some tweak here
                self.updatePageTheme()
            }
        }
    }
    
    func updatePageTheme(){
        if let coverPage = self.coverPage {
            coverPage.removeFromSuperview()
            self.coverPage = nil
            navigationController?.navigationBar.isHidden = false
            
        }
        if let article = article {
            if let themeColor = article.themeColor {
                addOrUpdateStatusBGView(viewController: self, color: themeColor)
                navigationController?.navigationBar.setBackgroundImage(article.themeImage, for: .default)
                UIApplication.shared.statusBarStyle = .lightContent
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                menuBtn.setImage(#imageLiteral(resourceName: "MenuLight"), for: .normal)
                actionBtn.setImage(#imageLiteral(resourceName: "ActionLight"), for: .normal)
                if tableView.backgroundView is ColoredView {
                    (tableView.backgroundView as! ColoredView).setTopHalfColor(color: themeColor)
                }else{
                    let coloredView = ColoredView(frame: self.view.bounds)
                    coloredView.setTopHalfColor(color: themeColor)
                    tableView.backgroundView = coloredView
                }
            } else {
                let defaultColor = UIColor(hexString: "F9F9F9")
                addOrUpdateStatusBGView(viewController: self, color: defaultColor)
                navigationController?.navigationBar.setBackgroundImage(article.themeImage, for: .default)
                UIApplication.shared.statusBarStyle = .default
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
                menuBtn.setImage(#imageLiteral(resourceName: "MenuDefault"), for: .normal)
                actionBtn.setImage(#imageLiteral(resourceName: "ActionDefault"), for: .normal)
                if tableView.backgroundView is ColoredView {
                    (tableView.backgroundView as! ColoredView).removeColorLayer()
                }
            }
        }
        
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func action(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
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
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
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
                var attributes: [String : Any]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SGNavCell") as! SGNavCell
                
                if let themeColor = article.themeColor {
                    attributes = [NSParagraphStyleAttributeName: paragraph,
                                  NSForegroundColorAttributeName: UIColor.white]
                    cell.prevBtn.layer.borderColor = UIColor.white.cgColor
                    cell.prevBtn.backgroundColor = themeColor
                    cell.nextBtn.layer.borderColor = UIColor.white.cgColor
                    cell.nextBtn.backgroundColor = themeColor
                } else {
                    attributes = [NSParagraphStyleAttributeName: paragraph]
                    cell.prevBtn.layer.borderColor = self.view.tintColor.cgColor
                    cell.prevBtn.backgroundColor = .white
                    cell.nextBtn.layer.borderColor = self.view.tintColor.cgColor
                    cell.nextBtn.backgroundColor = .white
                }
                
                cell.prevBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 10)
                cell.prevBtn.layer.borderWidth = 1
                cell.prevBtn.layer.cornerRadius = 5
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
                
                
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
                return cell
            }
            paragraph = article.paragraphs[indexPath.row]
        }
        
        switch paragraph.type {
        case .Plain, .Div:
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
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            }
            
            if paragraph.type == .Div {
                cell.backgroundColor = article?.themeColor
            } else {
                cell.backgroundColor = .white
            }
            
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgCell") as! SGImgCell
            
            if paragraph.cellHeight == 0 {
                if let imgWidth = paragraph.properties?["width"], let imgHeight = paragraph.properties?["height"] {
                    if let imgWidthInt = Int(imgWidth as! String), let imgHeightInt = Int(imgHeight as! String) {
                        
                        paragraph.imgViewHeight = CGFloat(Int(screenWidth - padding * 2) * imgHeightInt / imgWidthInt)
                    }
                }
                paragraph.cellHeight = paragraph.imgViewHeight + padding * 2
            }
            
            if let imgName = paragraph.properties?["src"] {
                CacheManager.getImage(withName: imgName as! String,
                                      completion: { (err, image) in
                                        DispatchQueue.main.async {
                                            cell.imgView.image = image
                                        }
                })
                
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
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
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
                CacheManager.getImage(withName: imgName as! String,
                                      completion: { (err, image) in
                                        DispatchQueue.main.async {
                                            cell.imgView.image = image
                                        }
                                        
                })
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
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            return cell
        }
    }
}

extension SGViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableTopInset != scrollView.contentInset.top {
            tableTopInset = scrollView.contentInset.top
            if(tableTopInset == 64){
                if let themeColor = article?.themeColor {
                    addOrUpdateStatusBGView(viewController: self, color: themeColor)
                    UIApplication.shared.statusBarStyle = .lightContent
                }else {
                    addOrUpdateStatusBGView(viewController: self, color: UIColor(hexString: "FFFFFF"))
                    UIApplication.shared.statusBarStyle = .default
                }
            }else{
                addOrUpdateStatusBGView(viewController: self, color: UIColor(hexString: "CFFFFFFF"))
                UIApplication.shared.statusBarStyle = .default
            }
        }
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
        if let article = article {
            if(article.menuId != self.article?.menuId){
                DispatchQueue.global(qos: .background).async {
                    self.article = article
                    self.article?.processContent()
                    DispatchQueue.main.async {
                        self.updatePageTheme()
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .right)//TODO: need some tweak here
                    }
                }
            }
        }
    }
}

