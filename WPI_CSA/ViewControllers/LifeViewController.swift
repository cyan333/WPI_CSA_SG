//
//  LifeViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/27/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import PassKit
import BraintreeDropIn
import Braintree

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

class LifeViewController: UIViewController ,PKAddPassesViewControllerDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var loadingView: LoadingView!
    //var serverDownView: UIView!
    
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
        
        /*============================== TESTING AREA STARTS ==============================*/
        
        
        
        /*============================== TESTING AREA ENDS ==============================*/
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Checking version info
        Utils.checkVerisonInfoAndLoginUser(onViewController: self, showingServerdownAlert: false)
        
        //Setting up loading view
        loadingView = LoadingView(frame: CGRect(x: 0, y: 64, width: screenWidth,
                                     height: screenHeight - 113))// 49 + 64
        let clickListener = UITapGestureRecognizer(target: self, action: #selector(refresh(_:)))
        loadingView.addGestureRecognizer(clickListener)
        self.view.addSubview(loadingView)
        
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
                if feedList.count < self.feedLoadLimit{
                    self.stopLoadingFlag = true
                }
                self.reloadingFlag = false
                self.tableView.reloadData()
                if error == serverDown {
                    self.loadingView.showServerDownView()
                } else {
                    self.loadingView.removeFromSuperview()
                }
            }
        }
        
        
    }
    
    @objc func refresh(_ sender: Any) {
        print(1)
        if reloadingFlag {
            return
        } else {
            stopLoadingFlag = false
            reloadingFlag = true
        }
        
        if serverDownFlag && sender is UITapGestureRecognizer {// Tap on screen when it shows server down
            loadingView.removeServerDownView()
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
                    self.loadingView.showServerDownView()
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
                    self.loadingView.showServerDownView()
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
    
    @IBAction func click(_ sender: Any) {/*
        let clientToken = "sandbox_5sx62kcq_wnbj3bx4nwmtyz77"
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientToken, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                print(result.paymentMethod?.nonce ?? "no nonce")
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)*/
        
        WCService.getTicket(withId: 1) { (error, pass) in
            if error == ""{
                let pkvc = PKAddPassesViewController(pass: pass!)
                pkvc.delegate = self
                self.present(pkvc, animated: true)
            } else {
                Utils.show(alertMessage: error, onViewController: self)
            }
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? FeedViewController {
            if let row = sender as? Int {
                destinationViewController.feed = feedList[row]
            }
        }
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
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "FeedSegue", sender: indexPath.row)
        }
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
            cell.coverShadow.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: screenWidth - 33, height: 200)).cgPath
            
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
