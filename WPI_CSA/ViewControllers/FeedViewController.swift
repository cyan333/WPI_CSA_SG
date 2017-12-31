//
//  FeedViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 10/1/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import EventKit
import PassKit
import Braintree
import BraintreeDropIn

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

class FeedEventCell: UITableViewCell {
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var button: UIButton!
}

class FeedButtonCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
}

class FeedViewController: UIViewController, PKAddPassesViewControllerDelegate {
    
    var feed: WCFeed!
    var article: Article!
    var event: WCEvent?
    
    var reloadingFlag = true //Loading from the beginning
    var loadingView: LoadingView!
    var feedTitleHeight: CGFloat = 80
    var feedEventTitleHeight: CGFloat = 35
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        article = Article(content: "")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Setting up loading view
        loadingView = LoadingView(frame: CGRect(x: 0, y: 64, width: screenWidth,
                                                height: screenHeight - 113))// 49 + 64
        let clickListener = UITapGestureRecognizer(target: self, action: #selector(refresh(_:)))
        loadingView.addGestureRecognizer(clickListener)
        self.view.addSubview(loadingView)
        
        WCFeedManager.getFeed(withId: feed.id) { (error, feed) in
            if error == "" {
                self.article = Article(content: feed!.body)
                self.article.processContent()
                if let event = feed?.event {
                    self.event = event
                }
            } else {
                print(error) //TODO: Do something here
            }
            self.reloadingFlag = false
            DispatchQueue.main.async {
                if error == "" {
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                } else if error == serverDown {
                    self.loadingView.showServerDownView()
                }
            }
        }
        
    }
    
    @objc func refresh(_ sender: Any) {
        if reloadingFlag {
            return
        } else {
            self.loadingView.removeServerDownView()
            reloadingFlag = true
        }
        
        WCFeedManager.getFeed(withId: feed.id) { (error, feed) in
            if error == "" {
                self.article = Article(content: feed!.body)
                self.article.processContent()
                if let event = feed?.event {
                    self.event = event
                }
            } else {
                print(error) //TODO: Do something here
            }
            
            self.reloadingFlag = false
            DispatchQueue.main.async {
                if error == "" {
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                } else if error == serverDown {
                    self.loadingView.showServerDownView()
                }
            }
        }
        
    }
    
    @objc func addToCalendar() {
        if let event = event {
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted {
                    //Deplicate check
                    let eventsPredicate = eventStore.predicateForEvents(withStart: event.startTime, end: event.endTime,
                                                                        calendars: [eventStore.defaultCalendarForNewEvents!])
                    let matches = eventStore.events(matching: eventsPredicate)
                    
                    
                    for e in matches {
                        if e.title == event.title {
                            var style = ToastStyle()
                            style.messageAlignment = .center
                            DispatchQueue.main.async {
                                self.view.makeToast("Already added to calendar", duration: 2.0, position: .center, style: style)
                            }
                            return
                        }
                    }
                    
                    //Added to calendar
                    let calendarEvent = EKEvent(eventStore: eventStore)
                    calendarEvent.title = event.title
                    calendarEvent.notes = event.description
                    calendarEvent.startDate = event.startTime
                    calendarEvent.endDate = event.endTime
                    calendarEvent.location = event.location
                    calendarEvent.alarms = [EKAlarm(relativeOffset: -86400)] //24 hour before
                    calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(calendarEvent, span: .thisEvent)
                        var style = ToastStyle()
                        style.messageAlignment = .center
                        DispatchQueue.main.async {
                            self.view.makeToast("Added to calendar successfully", duration: 2.0, position: .center, style: style)
                        }
                    } catch let e  {
                        Utils.show(alertMessage: "Failed to save event. \(e.localizedDescription)", onViewController: self)
                    }
                } else {
                    Utils.show(alertMessage: "We don't have access for your calendar. Please either reinstall the app or reset app privacy by Settings -> General -> Reset -> Reset Location & Privacy", onViewController: self)
                }
                
            })
            
        } else {
            Utils.show(alertMessage: "Internal error. Please contact admin@fmning.com", onViewController: self)//TODO: Put his msg in common place
        }
    }
    
    @objc func payAndGetTicket() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Utils.show(alertMessage: "This feature is not supported from iPad",
                       onViewController: self)
        } else if Utils.appMode != .LoggedOn{
            Utils.show(alertMessage: "You have to log in to buy ticket", onViewController: self)
        } else if event!.fee! > 0 {
            let clientToken = "sandbox_bk8pdqf3_wnbj3bx4nwmtyz77"
            
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
            self.present(dropIn!, animated: true, completion: nil)
        } else {
            guard let username = WCService.currentUser?.username else {
                Utils.show(alertMessage: "Unknown error. Please contact admin@fmning.com", onViewController: self)
                return
            }
            if !username.trim().lowercased().hasSuffix("@wpi.edu") {
                Utils.show(alertMessage: "To get free ticket, you have to log in with your wpi email, with the email verified.",
                           onViewController: self)
            } else if !WCService.currentUser!.emailConfirmed {
                Utils.show(alertMessage: "Please go to App Setting and verify your email before buying ticket", onViewController: self)
            } else {
                Utils.showLoadingIndicator()
                WCPaymentManager.makePayment(for: "Event", withId: event!.id, paying: event!.fee!,
                                             completion: { (error, status, ticketStatus, ticketId, ticket) in
                    Utils.hideIndicator()
                    if error != "" {
                        Utils.show(alertMessage: error, onViewController: self)
                    } else {
                        if status == "ok" {
                            if ticketStatus == "ok" {
                                let ticketView = PKAddPassesViewController(pass: ticket!)
                                ticketView.delegate = self
                                self.present(ticketView, animated: true)
                            } else {
                                Utils.show(alertMessage: "Transaction is successful. " + ticketStatus
                                    + "Please contact admin@fmning.com", onViewController: self)
                            }
                        } else if status == "AlreadyPaid"{
                            let alert = UIAlertController(title: nil, message: "You have already paid for it. Do you want to download ticket again?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                Utils.showLoadingIndicator()
                                WCService.getTicket(withId: ticketId!, completion: { (error, ticket) in
                                    Utils.hideIndicator()
                                    if error == "" {
                                        let ticketView = PKAddPassesViewController(pass: ticket!)
                                        ticketView.delegate = self
                                        self.present(ticketView, animated: true)
                                    } else {
                                        Utils.show(alertMessage: error, onViewController: self)
                                    }
                                })
                            }))
                            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            Utils.show(alertMessage: "Unknown status " + status, onViewController: self)
                        }
                    }
                })
            }
        }
    }
    
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return feedTitleHeight + 60
        } else if indexPath.section == 1 {
            return article.paragraphs[indexPath.row].cellHeight
        } else {
            if indexPath.row == 0 {
                return 125 + feedEventTitleHeight
            } else {
                return 44
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 2
        if event != nil {
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return article.paragraphs.count
        } else {
            if event!.fee == nil{
                return 1
            } else {
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTitleCell") as! FeedTitleCell
            
            cell.title.text = feed.title
            let size = cell.title.sizeThatFits(CGSize(width: screenWidth - padding * 2,
                                                      height: .greatestFiniteMagnitude))
            feedTitleHeight = size.height
            
            cell.type.text = " " + feed.type + " "
            cell.type.layer.borderWidth = 1
            cell.type.layer.borderColor = UIColor.gray.cgColor
            cell.type.layer.cornerRadius = 10
            cell.date.text = feed.createdAt.toString
            cell.ownerName.text = feed.ownerName
            
            let filteredConstraints = cell.title.constraints.filter { $0.identifier == "feedTitleHeight" }
            if let heightConstraint = filteredConstraints.first {
                heightConstraint.constant = feedTitleHeight
            }
            
            return cell
        } else if indexPath.section == 1 {
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
            
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedEventCell") as! FeedEventCell
                //feedEventTitleHeight
                cell.title.text = event!.title
                let size = cell.title.sizeThatFits(CGSize(width: screenWidth - padding * 3,
                                                          height: .greatestFiniteMagnitude))
                feedEventTitleHeight = size.height
                
                cell.date.text = event!.startTime.toString + " to " + event!.endTime.toString
                cell.location.text = "Location: " + event!.location
                cell.button.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
                
                let filteredConstraints = cell.title.constraints.filter { $0.identifier == "feedEventTitleHeight" }
                if let heightConstraint = filteredConstraints.first {
                    heightConstraint.constant = feedEventTitleHeight
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedButtonCell") as! FeedButtonCell
                if event!.fee == 0 {
                    cell.button.setTitle("Free - Get ticket", for: .normal)
                } else {
                    cell.button.setTitle("$\(event!.fee!) - Pay and get ticket", for: .normal)
                }
                
                cell.button.addTarget(self, action: #selector(payAndGetTicket), for: .touchUpInside)
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
                return cell
            }
            
        }
        
    }
    
    
}

