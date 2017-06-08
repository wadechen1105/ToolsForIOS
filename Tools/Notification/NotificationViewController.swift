//
//  NotificationViewController.swift
//  Tools
//
//  Created by Wade.Chen on 2017/2/6.
//  Copyright © 2017年 wade.wade. All rights reserved.
//
import UIKit
import Foundation

class NotificationViewController: UIViewController {
    override var className: String {
        return String(describing: NotificationViewController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //fix This is the default "parallax" behavior triggered by the pushViewController:animated: method.
        // use the same background color with root navigation view controller
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = className

        //        let settings = UIUserNotificationSettings(types: UIUserNotificationType.alert | UIUserNotificationType.badge | UIUserNotificationType.sound, categories: nil)
    }
    
}
