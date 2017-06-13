//
//  DownloadViewController.swift
//  Tools
//
//  Created by Wade.Chen on 2017/6/13.
//  Copyright © 2017年 wade.wade. All rights reserved.
//

import Foundation
import UIKit

class DownloadViewController: ParentViewController, DownloadComplereCallback {

    let imageView: UIImageView = UIImageView()

    override var className: String {
        return String(describing: DownloadViewController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.frame = CGRect(x: 108, y: 8, width: 150, height: 150)
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.brown.cgColor
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        let request = URLRequest(url: URL(string: "http://www.joy.org.tw/wallpaper/Joy148-L.jpg")!)
        DownloadTask(self).doDownload(request)
    }

    func onFinish(_ fileURL: URL) {
        DispatchQueue.main.async {
            Log.d("url : \(fileURL)")
            UIView.transition(with: self.imageView,
                              duration: 0.3,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {self.imageView.image = UIImage(contentsOfFile: fileURL.path)},
                              completion: nil)
        }
    }
}
