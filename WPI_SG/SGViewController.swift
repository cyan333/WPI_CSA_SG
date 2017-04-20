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
let coverImg = "<img src=\"1_1.jpg\" height=\"450\" width=\"450\"/>"

protocol MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?)
    func reopenMenu()
    func displayArticleAndSaveMenuState(article: Article?, menuList: [Menu])
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
    
    var menuList = [Menu]()
    
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
        
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "openMenu", sender: nil)
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
            destinationViewController.menuList = self.menuList
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
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
                let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width,
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
            
            //cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
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
            
            //cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        case .ImageText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            
            if paragraph.cellHeight == 0 {
                cell.textView.attributedText = paragraph.content
                let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width,
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
            //cell.contentView.translatesAutoresizingMaskIntoConstraints = true
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
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
    
    func displayArticleAndSaveMenuState(article: Article?, menuList: [Menu]){
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

