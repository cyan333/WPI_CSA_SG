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

class FeedImageCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
}

class FeedViewController: UIViewController {
    
    var feed: WCFeed!
    var article: Article!
    var event: WCEvent?
    var titleHeight: CGFloat = 80
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()//test
        article = Article(content: feed.body)// + "<img src=\"cover.jpg\" height=\"1836\" width=\"1200\"/>")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        DispatchQueue.global(qos: .background).async {
            self.article.processContent()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        if feed.type == "Event"{
            WCEventManager.getEvent(withMappingId: feed.id, completion: { (error, event) in
                if error == "" {
                    self.event = event
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print(error)//TODO: Do something here
                }
            })
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
            let paragraph = article.paragraphs[indexPath.row]
            switch paragraph.type {
            case .Plain :
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTextCell") as! FeedTextCell
                
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
            case .Image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
                
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
                    
                    let filteredConstraints = cell.imgView.constraints.filter { $0.identifier == "feedImgCellHeight" }
                    if let heightConstraint = filteredConstraints.first {
                        heightConstraint.constant = paragraph.imgViewHeight
                    }
                }else{
                    //TODO: friendly error message?
                    print("Cannot read image")
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTextCell") as! FeedTextCell
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
                return cell
            }
            
            
            
            //feedTextCellHeight
            
        }
        
    }
    
    
}

