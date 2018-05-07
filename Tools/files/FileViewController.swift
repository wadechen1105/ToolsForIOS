//
//  FileViewController.swift
//  Tools
//
//  Created by Wade H-C Chen on 2018/4/18.
//  Copyright © 2018年 wade.wade. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class FileViewController : ParentViewController, UIDocumentInteractionControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let position = self.view.center
        let size = CGSize(width: 100.0, height: 50.0)
        
        let button = UIButton(type: .roundedRect)
        button.frame.size = size
        
        button.frame.origin.x = position.x - button.frame.size.width / 2
        button.frame.origin.y = position.y - button.frame.size.height / 2
        
        button.setTitle("點擊 .ics",for: .normal)
        button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    @objc func click(_ b: Any) {
        guard let url = Bundle.main.url(forResource: "myevents", withExtension: "ics") else {
            print("file url incorrect")
            return
        }
        //
        //
        //        let dc = UIDocumentInteractionController(url: url)
        //        dc.delegate = self
        //        dc.presentPreview(animated: true)
        
        let calendarManager = MXLCalendarManager();
        calendarManager .scanICSFile(atLocalPath: url.path) {
            mxlcalendar, error in
            
            guard let calendar = mxlcalendar else {
                return
            }
            let store = EKEventStore()
            for event in calendar.events {
                let e = event as! MXLCalendarEvent
                let ekevent = e.convertToEKEvent(on: e.eventStartDate, store: store)
                print("## title \(String(describing: ekevent?.title)) , desc \(String(describing: ekevent?.description)), start date \(String(describing: ekevent?.startDate))")
            }
            
            //TODO: how to convert MXLCalendarEvent to EKEvent
            var ek = EKEvent(eventStore: store)
        }
        
        
        //
        //        let store = EKEventStore()
        //        store.requestAccess(to: .event){
        //            (granted, error) in
        //            if !granted { return }
        //            var event = EKEvent(eventStore: store)
        //            event.title = "Test Event Title"
        //            event.startDate = Date() //today
        //            event.endDate = event.startDate.addingTimeInterval(60 * 60) //1 hour long meeting
        //            event.calendar = store.defaultCalendarForNewEvents
        //
        //            do {
        //                try store.save(event, span: .thisEvent, commit: true)
        //            } catch {
        //                // Display error to user
        //            }
        //        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}
