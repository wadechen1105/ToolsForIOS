//
//  WImageLabelView.swift
//  Tools
//
//  Copyright © 2017年 wade.wade. All rights reserved.
//

import Foundation
import UIKit

public enum Position {
    case top, left, bottom, right
}

public class WImageLabelView: UIView {
    private let Padding: CGFloat = 5
    private var cLabel: UILabel?
    private var cImage = UIImageView()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        addTextView()
        addImage()
    }
    
    ///
    // add defaut UILabel
    //
    private func addTextView() {
        cLabel = UILabel()
        cLabel!.frame.origin = CGPoint(x: Padding, y: Padding)
        self.setLabelViewSize()
        self.setText()
        self.addSubview(cLabel!)
        updateLayout()
    }
    
    func setText(text: String = "new Label") {
        cLabel!.text = text
    }
    
    func setTextColor(color: UIColor = UIColor.black) {
        cLabel!.textColor = color
    }
    
    func setLabelViewSize(size: CGSize = CGSize(width: 100, height: 20)) {
        cLabel!.frame.size = size
    }
    
    ///If change subview's position, must call this to refit subviews
    func updateLayout() {
        var w: CGFloat = 0
        var h: CGFloat = 0
        
        for view in self.subviews {
            //releative position
            let fw = abs(view.frame.origin.x) + view.frame.width
            let fh = abs(view.frame.origin.y) + view.frame.height
            
            w = max(fw, w)
            h = max(fh, h)
        }
        
        self.frame.size = CGSize(width: w + Padding, height: h + Padding)
    }
    
    func addImage(to: Position = .left, size: CGSize = CGSize(width: 50, height: 50), src: UIImage? = nil) {
        
        guard cLabel != nil, !cImage.isDescendant(of: self) else {
            fatalError("It is nil or had added to parent already")
        }
        
        // change image frame ro label frame
        cImage.frame.origin = cLabel!.frame.origin
        cImage.frame.size = size
        
        switch to {
        case .top:
            // move label frame below image
            cLabel!.frame.origin.y += (Padding + size.height)
            cImage.center.x = cLabel!.frame.width/2 + Padding
            break
        case .left:
            // move label frame to left of image
            cLabel!.frame.origin.x += (Padding + size.width)
            cLabel!.center.y = size.height/2 + Padding
            break
        case .bottom:
            // move Image frame to bottom
            cImage.frame.origin.y += (Padding + cLabel!.frame.height)
            cImage.center.x = cLabel!.frame.width/2 + Padding
            break
        case .right:
            // move Image frame to right
            cImage.frame.origin.x += (Padding + cLabel!.frame.width)
            cLabel!.center.y = size.height/2 + Padding
            break
        }
        
        Log.d("1, label position = \(String(describing: cLabel!.frame.origin))")
        Log.d("2, image position = \(String(describing: cImage.frame.origin))")
        
        if let img = src {
            cImage.image = img
        } else {
            // set default color
            cImage.backgroundColor = UIColor.black
        }
        
        self.addSubview(cImage)
        updateLayout()
    }
}
