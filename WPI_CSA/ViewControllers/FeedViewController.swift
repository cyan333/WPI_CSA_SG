//
//  FeedViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 10/1/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class FeedTitleCell: UITableViewCell {
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var ownerName: UILabel!
}

class FeedTextCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
}

class FeedViewController: UIViewController {
    
    var feed: WCFeed!
    var article: Article!
    var titleHeight: CGFloat = 80
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        article = Article(content: feed.body)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        DispatchQueue.global(qos: .background).async {
            self.article.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return titleHeight + 60
        } else {
            return article.paragraphs[indexPath.row].cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return article.paragraphs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTitleCell") as! FeedTitleCell
            
            cell.title.text = feed.title
            let size = cell.title.sizeThatFits(CGSize(width: screenWidth - padding * 2,
                                                      height: .greatestFiniteMagnitude))
            titleHeight = size.height
            
            cell.type.text = " " + feed.type + " "
            cell.type.layer.borderWidth = 1
            cell.type.layer.borderColor = UIColor.gray.cgColor
            cell.type.layer.cornerRadius = 10
            cell.date.text = feed.createdAt.toString
            cell.ownerName.text = feed.ownerName
            
            let filteredConstraints = cell.title.constraints.filter { $0.identifier == "feedTitleHeight" }
            if let heightConstraint = filteredConstraints.first {
                heightConstraint.constant = titleHeight
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTextCell") as! FeedTextCell
            
            let paragraph = article.paragraphs[indexPath.row]
            cell.textView.attributedText = paragraph.content
            
            if paragraph.cellHeight == 0 {
                let size = cell.textView.sizeThatFits(CGSize(width: screenWidth - padding * 2,
                                                             height: .greatestFiniteMagnitude))
                paragraph.textViewHeight = size.height
                paragraph.cellHeight = size.height
            }
            
            let filteredConstraints = cell.textView.constraints.filter { $0.identifier == "feedTextCellHeight" }
            if let heightConstraint = filteredConstraints.first {
                heightConstraint.constant = paragraph.textViewHeight
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
            
            return cell
            
        }
        
    }
    
    
}

