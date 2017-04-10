//
//  MainViewController.swift
//  WPI SG
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

protocol MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?)
    func reopenMenu()
    func saveMenuState(menuList: [Menu])    
}

class SGImgTextCell: UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
}

class SGTextCell: UITableViewCell{
    @IBOutlet weak var textView: UITextView!
}

class SGViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    
    var menuList = [Menu]()
    
    var article = Article(title: "", content: "")
    
    override func viewDidLoad() {
        //tableView.estimatedRowHeight = 44;
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let b = "123<img src=\"1_1.jpg\" height=\"450\" weight=\"450\"><span style=\"font-size:14px;font-weight:bold;\">President</span>\n陆安琪 Anqi Lu\nalu@wpi.edu\nComputer Science & Mathematical Science '18</img><img src=\"1_1.jpg\" height=\"450\" weight=\"450\"><span style=\"font-size:14px;font-weight:bold;\">Vice President</span>\n周梓雨 Ziyu Zhou\nzzhou2@wpi.edu\nManagement Information System '17</img>1"
        
        
        article = Article(title: "Sample Title", content: b)
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
        return article.paragraphs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(article.paragraphs[indexPath.row].cellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paragraph = article.paragraphs[indexPath.row]
        switch paragraph.type {
        case .Plain:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
            
            cell.textView.text = paragraph.content
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
            
            cell.textView.text = "Image only cell"
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        case .ImageText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            
            cell.textView.text = paragraph.content
            let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width,
                                                         height: CGFloat.greatestFiniteMagnitude))
            paragraph.cellHeight = Double(size.height)
            cell.textView.frame.size = size
            cell.imgView.image = UIImage(named: paragraph.properties?["src"] as! String)
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
        }
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
        
        cell.imgView.image = UIImage(named: "1_1.jpg")
        
        let a = "<span style=\"font-size:14px;font-weight:bold;\">President</span><br/>陆安琪 Anqi Lu<br/>fning@wpi.edu<br/>Computer Science & Mathematical Science \'18"
        
        DispatchQueue.global(qos: .background).async {
            let html = a.htmlAttributedString()
            DispatchQueue.main.async {
                cell.textView.attributedText = html
            }
        }*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
        
        cell.textView.text = "haha wtf"
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return cell
    }
}

extension SGViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
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
    
    func saveMenuState(menuList: [Menu]){
        self.menuList = menuList
    }
}

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil) else { return nil }
        return html
    }
}
