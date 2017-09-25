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

class LifeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var loadingView: UIView!
    var flag = true
    
    var feedList = [WCFeed]()
    var checkPoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        //CacheManager.localDirInitiateSetup()
    
        /*CacheManager.getImage(withName: "WCImage_3") { (error, img ) in
            if error != "" {
                print(error)
            } else if let img = img {
                DispatchQueue.main.async {
                    let a = UIImageView(image: img)
                    self.tableView.backgroundView = a
                }
            } else{
                print("img nil")
            } 
         }*/
        
        /*if let dateFromString = "2015-12-12T23:29:43.538550Z".dateFromISO8601 {
            print(dateFromString.iso8601)
        }*/
        
        WCFeedManager.getRecentFeeds(withLimit: 5, andCheckPoint: checkPoint) { (error, feedList, checkPoint) in
            if error == "" {
                self.feedList = feedList
                self.checkPoint = checkPoint
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadingView.removeFromSuperview()
                }
            } else {
                print(error)
            }
        }
        
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: false)
        
        let loadingViewHeight = screenHeight - 113 // 49 + 64
        loadingView = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth,
                                     height: loadingViewHeight))
        //loadingView.backgroundColor = .red
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: screenWidth/2 - 60, y: loadingViewHeight/2 - 15,
                                                                     width: 30, height: 30))
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        loadingView.addSubview(loadingIndicator)
        
        
        let loadingLabel = UILabel(frame: CGRect(x: screenWidth/2 - 30, y: loadingViewHeight/2 - 15,
                                                 width: 80, height: 30))
        loadingLabel.text = "Loading ..."
        loadingLabel.textColor = .gray
        //loadingLabel.backgroundColor = .green
        loadingView.addSubview(loadingLabel)
        
        self.view.addSubview(loadingView)
    }
    
    func refresh(_ sender: Any) {
        print(1)
        
        refreshControl.endRefreshing()        
    }
    
    @IBAction func click(_ sender: Any) {
        
        if flag {
            flag = false
            loadingView.removeFromSuperview()
        } else {
            flag = true
            self.view.addSubview(loadingView)
        }
        
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //print(1)
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath) as! RegisterInputCell
        //cell.textField.becomeFirstResponder()
        //print(1)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension LifeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.ownerName.text = String(feed.id)
        cell.createdAt.text = feed.createdAt.toString
        
        return cell
    }
    

}
