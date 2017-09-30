//
//  LifeViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/27/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import EventKit

let padding: CGFloat = 10
let imgViewWidth: Int = 130
let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height

class FeedCell: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var coverShadow: UIView!
    @IBOutlet weak var avatarShadow: UIView!
}

class FeedLoadingCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var coverLabel: UILabel!
}

class LifeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var loadingView: UIView!
    var serverDownView: UIView!
    
    var feedList = [WCFeed]()
    var checkPoint: String?
    var serverDownFlag = false
    var reloadingFlag = false
    var keepLoadingFlag = false
    var stopLoadingFlag = false
    
    var noMoreFeedMsg = "There are no more articles."
    
    let feedLoadLimit = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CacheManager.localDirInitiateSetup()
        
        /*let a = UIImage(named: "test.jpg")
        let data = UIImageJPEGRepresentation(a!, 0)
        let b = NSData(data: data!)
        print("\(Double(b.length)/1024)")
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0] as NSString
        print(documentDirectoryPath)
        let imgPath = documentDirectoryPath.appendingPathComponent("1.jpg")
        do{
            try data?.write(to: URL(fileURLWithPath: imgPath),
                                                             options: .atomic)
        }catch let error{
            print(error.localizedDescription)
        }*/
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Checking version info
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: false)
        
        //Setting up loading view
        let loadingViewHeight = screenHeight - 113 // 49 + 64
        loadingView = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth,
                                     height: loadingViewHeight))
        loadingView.backgroundColor = .white
        let clickListener = UITapGestureRecognizer(target: self, action: #selector(refresh(_:)))
        loadingView.addGestureRecognizer(clickListener)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: screenWidth/2 - 60, y: loadingViewHeight/2 - 15,
                                                                     width: 30, height: 30))
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        loadingView.addSubview(loadingIndicator)
        
        
        let loadingLabel = UILabel(frame: CGRect(x: screenWidth/2 - 30, y: loadingViewHeight/2 - 15,
                                                 width: 80, height: 30))
        loadingLabel.text = "Loading ..."
        loadingLabel.textColor = .gray
        loadingView.addSubview(loadingLabel)
        
        self.view.addSubview(loadingView)
        
        serverDownView = UIView(frame: CGRect(x: screenWidth/2 - 150, y: loadingViewHeight/2 - 100,
                                              width: 300, height: 200))
        serverDownView.backgroundColor = .white
        
        let refreshImg = UIImageView(frame: CGRect(x: 90, y: 0, width: 120, height: 120))
        refreshImg.image = #imageLiteral(resourceName: "Reload")
        serverDownView.addSubview(refreshImg)
        
        //Setting up warning view
        let warningView = UITextView(frame: CGRect(x: 0, y: 130, width: 300, height: 50))
        warningView.text = "There is an network issue. Click anywhere to refresh the page.\nIf still doesn't work, please contact admin@fmning.com"
        warningView.font = UIFont(name: (warningView.font?.fontName)!, size: 10)
        warningView.textColor = .gray
        warningView.textAlignment = .center
        warningView.dataDetectorTypes = .all
        warningView.isEditable = false
        serverDownView.addSubview(warningView)
        
        //Requesting for feeds
        reloadingFlag = true
        WCFeedManager.getRecentFeeds(withLimit: feedLoadLimit, andCheckPoint: checkPoint) {
            (error, feedList, checkPoint) in
            if error == "" {
                self.feedList = feedList
                self.checkPoint = checkPoint
            } else {
                print(error)// Do nothing if there are no feed
            }
            
            DispatchQueue.main.async {
                self.reloadingFlag = false
                self.tableView.reloadData()
                if error == serverDown {
                    self.loadingView.addSubview(self.serverDownView)
                } else {
                    if feedList.count < self.feedLoadLimit{
                        self.stopLoadingFlag = true
                    }
                    self.loadingView.removeFromSuperview()
                }
            }
        }
        
        
    }
    
    @objc func refresh(_ sender: Any) {
        if reloadingFlag {
            return
        } else {
            stopLoadingFlag = false
            reloadingFlag = true
        }
        
        if serverDownFlag && sender is UITapGestureRecognizer {// Tap on screen when it shows server down
            serverDownView.removeFromSuperview()
        }
        checkPoint = nil
        WCFeedManager.getRecentFeeds(withLimit: feedLoadLimit, andCheckPoint: checkPoint) {
            (error, feedList, checkPoint) in
            if error == "" {
                self.feedList = feedList
                self.checkPoint = checkPoint
            } else {
                print(error)
            }
            DispatchQueue.main.async {
                if error == serverDown {
                    self.serverDownFlag = true
                    self.loadingView.addSubview(self.serverDownView)
                    self.view.addSubview(self.loadingView)
                } else {
                    if feedList.count < self.feedLoadLimit {
                        self.stopLoadingFlag = true
                    }
                    self.loadingView.removeFromSuperview()
                    self.serverDownFlag = false
                }
                self.reloadingFlag = false
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        }
        
    }
    
    func keepLoading() {
        if keepLoadingFlag {
            return
        } else {
            keepLoadingFlag = false
        }
        
        WCFeedManager.getRecentFeeds(withLimit: feedLoadLimit, andCheckPoint: checkPoint) {
            (error, feedList, checkPoint) in
            if error == "" {
                self.feedList.append(contentsOf: feedList)
                self.checkPoint = checkPoint
            } else {
                print(error)
            }
            DispatchQueue.main.async {
                if error == serverDown {
                    self.serverDownFlag = true
                    self.loadingView.addSubview(self.serverDownView)
                    self.view.addSubview(self.loadingView)
                } else {
                    if feedList.count < self.feedLoadLimit {
                        self.stopLoadingFlag = true
                    }
                }
                self.keepLoadingFlag = false
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    @IBAction func click(_ sender: Any) {
        
        
        /*let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let start = formatter.date(from: "2017/08/27 18:00")
        let end = formatter.date(from: "2017/08/27 22:00")
        
        let eventStore = EKEventStore()
        
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: start!, end: end!,
                                                            calendars: [eventStore.defaultCalendarForNewEvents])
        
        let a = eventStore.events(matching: eventsPredicate)
        
        
        for e in a {
            print(e.title)
        }
        
        addEventToCalendar(title: "CSA event", description: "Come here on thursday",
                           startDate: start!, endDate: end!) { (status, error) in
                            if status {
                                print("ok")
                            }else{
                                print(error?.localizedDescription ?? "nil")
                            }
        }*/
    }
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        print(55)
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                print(1)
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    print(2)
                    try eventStore.save(event, span: .thisEvent)
                    print(3)
                } catch let e  {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error )
            }
        })
    }
    
}

extension LifeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 300
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !stopLoadingFlag && indexPath.section == 0 && indexPath.row == feedList.count - 1 {
            keepLoading()
        }
    }
    
}

extension LifeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return feedList.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedCell
            let feed = feedList[indexPath.row]
            
            cell.coverShadow.layer.shadowColor = UIColor.lightGray.cgColor
            cell.coverShadow.layer.shadowOpacity = 0.5
            cell.coverShadow.layer.shadowOffset = CGSize(width: -1, height: 1)
            cell.coverShadow.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: screenWidth - 30, height: 200)).cgPath
            
            cell.avatarShadow.layer.shadowColor = UIColor.lightGray.cgColor
            cell.avatarShadow.layer.shadowOpacity = 0.5
            cell.avatarShadow.layer.shadowOffset = CGSize(width: -1, height: 1)
            cell.avatarShadow.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 80, height: 75)).cgPath
            
            cell.title.text = feed.title
            cell.type.text = feed.type
            cell.ownerName.text = feed.ownerName
            cell.createdAt.text = feed.createdAt.toString
            
            if let avatarId = feed.avatarId {
                CacheManager.getImage(withName: avatarId.toWCImageId(), completion: { (error, image) in
                    DispatchQueue.main.async {
                        if error == "" {
                            cell.avatar.image = image
                        } else {
                            cell.avatar.image = #imageLiteral(resourceName: "defaultAvatar.png")
                        }
                    }
                    
                })
            } else {
                cell.avatar.image = #imageLiteral(resourceName: "defaultAvatar.png")
            }
            
            cell.coverImage.image = UIImage(color: .white)
            if let coverId = feed.coverImgId {
                CacheManager.getImage(withName: coverId.toWCImageId(), completion: { (error, image) in
                    DispatchQueue.main.async {
                        if error == "" {
                            cell.coverImage.image = image
                        }
                    }
                })
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedLoadingCell") as! FeedLoadingCell
            
            cell.activityIndicator.startAnimating()
            if stopLoadingFlag {
                cell.coverLabel.backgroundColor = .white
                cell.coverLabel.text = noMoreFeedMsg
            } else {
                cell.coverLabel.backgroundColor = UIColor(white: 1, alpha: 0)
                cell.coverLabel.text = ""
            }
            
            return cell
        
        }
        
    }
    

}
