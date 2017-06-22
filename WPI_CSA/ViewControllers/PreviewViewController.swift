//
//  PreviewViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 6/18/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class PreviewTextCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
}

class PreviewViewController: UIViewController {
    var attributedTitle: NSAttributedString?
    var attributedArtile: NSAttributedString?
    
    var cellHeighs: [CGFloat] = [60, 60]
    var menuId: Int?     
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    @IBAction func submitClicked(_ sender: Any) {
        
        Utils.showLoadingIndicator()
        WCArticleManager.submitArticle(withTitle: SGDatabase.getParam(named: localTitle)!.replacingOccurrences(of: "\n", with: ""),
                                       andArticle: SGDatabase.getParam(named: localArticle)!.replacingOccurrences(of: "\n", with: ""),
                                       underMenu: menuId!) { (error) in
            if error == "" {
                Utils.dismissIndicator()
                self.dismiss(animated: true, completion: nil)
                let messageDict = ["message": "Thank you for your contribution. We have received your article and it's under validation now."]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showToast"), object: nil, userInfo: messageDict)
            }else{
                SGDatabase.setParam(named: localTitle, withValue: "")
                SGDatabase.setParam(named: localArticle, withValue: "")
                Utils.dismissIndicator()
                Utils.process(errorMessage: error, onViewController: self, showingServerdownAlert: true)
            }
        }
    }
    
    
    
}


extension PreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewTextCell") as! PreviewTextCell
        if indexPath.row == 0 {
            if let attributedTitle = attributedTitle {
                cell.textView.attributedText = attributedTitle
            }
        }else {
            if let attributedArtile = attributedArtile {
                cell.textView.attributedText = attributedArtile
            }
        }
        
        let size = cell.textView.sizeThatFits(CGSize(width: cell.frame.width - 20,
                                                     height: .greatestFiniteMagnitude))
        cellHeighs[indexPath.row] = size.height
        
        let filteredConstraints = cell.textView.constraints.filter { $0.identifier == "previewCellTextHeight" }
        if let heightConstraint = filteredConstraints.first {
            heightConstraint.constant = size.height
        }
        
        return cell
    }
}

extension PreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeighs[indexPath.row]
    }
}
