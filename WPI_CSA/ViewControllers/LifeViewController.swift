//
//  LifeViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/27/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit
import EventKit

class LifeViewController: UIViewController {
    
    override func viewDidLoad() {
        
        
    }
    
    @IBAction func click(_ sender: Any) {
        
        WCImageManager.uploadImg { (error) in
            print(error)
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
