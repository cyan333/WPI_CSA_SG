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
        
        
        let b = "<img src=\"1_1.jpg\" height=\"450\" width=\"450\"><span style=\"font-size:14px;font-weight:bold;\">President</span><br>陆安琪 Anqi Lu<br>alu@wpi.edu<br>Computer Science & Mathematical Science '18</img><img src=\"1_1.jpg\" height=\"450\" width=\"450\"><span style=\"font-size:14px;font-weight:bold;\">Vice President</span><br>周梓雨 Ziyu Zhou<br>zzhou2@wpi.edu<br>Management Information System '17<br><br><br><br>111<br>111<br>11111</img>"
        
        
        article = Article(title: "<h5>Sample Title with some good shit</h5>", content: b)
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
        return article.paragraphs[indexPath.row].cellHeight
        //return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paragraph = article.paragraphs[indexPath.row]
        switch paragraph.type {
        case .Plain:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
            
            if paragraph.cellHeight == 0 {
                DispatchQueue.global(qos: .background).async {
                    let html = paragraph.content.htmlAttributedString()
                    DispatchQueue.main.async {
                        cell.textView.attributedText = html
                        let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width,
                                                                     height: .greatestFiniteMagnitude))
                        paragraph.processedContent = html
                        paragraph.textViewHeight = size.height - 30
                        paragraph.cellHeight = size.height - 30
                        //paragraph.content = "" Sample code to clean up memory
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }else{
                cell.textView.attributedText = paragraph.processedContent
                cell.textView.heightAnchor.constraint(equalToConstant: paragraph.textViewHeight).isActive = true
            }
            //cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGTextCell") as! SGTextCell
            
            cell.textView.text = "Image only cell"
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            
            return cell
        case .ImageText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SGImgTextCell") as! SGImgTextCell
            
            if paragraph.cellHeight == 0 {
                DispatchQueue.global(qos: .background).async {
                    let html = paragraph.content.htmlAttributedString()
                    DispatchQueue.main.async {
                        cell.textView.attributedText = html
                        let size = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width,
                                                                     height: .greatestFiniteMagnitude))
                        paragraph.processedContent = html
                        paragraph.textViewHeight = size.height
                        if let imgWidth = paragraph.properties?["width"], let imgHeight = paragraph.properties?["height"] {
                            if let imgWidthInt = Int(imgWidth as! String), let imgHeightInt = Int(imgHeight as! String) {
                                paragraph.imgViewHeight = CGFloat(130 * imgHeightInt / imgWidthInt) //130 is the default image view width
                            }
                        }
                        if paragraph.textViewHeight > paragraph.imgViewHeight {
                            paragraph.cellHeight = paragraph.textViewHeight + 20
                        }else{
                            paragraph.cellHeight = paragraph.imgViewHeight + 20
                        }
                        //paragraph.content = "" Sample code to clean up memory
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }else{
                cell.textView.attributedText = paragraph.processedContent
                cell.textView.heightAnchor.constraint(equalToConstant: paragraph.textViewHeight).isActive = true
                
                if let imgName = paragraph.properties?["src"] {
                    cell.imgView.image = UIImage(named: imgName as! String)
                    cell.imgView.heightAnchor.constraint(equalToConstant: paragraph.imgViewHeight).isActive = true
                }else{
                    //TODO: friendly error message?
                    print("Cannot read image")
                }
            }
            //cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            cell.contentView.translatesAutoresizingMaskIntoConstraints = true
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
