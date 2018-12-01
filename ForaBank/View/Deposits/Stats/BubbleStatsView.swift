//
//  BubbleStatsView.swift
//  ForaBank
//
//  Created by Sergey on 30/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class BubbleStatsView: UIView {

    let textLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
//        l.backgroundColor = .black
        l.textAlignment = .center
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 12)
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let secondTextLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 1
        l.lineBreakMode = .byWordWrapping
//        l.backgroundColor = .red
        l.textAlignment = .center
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    var scale: CGFloat = 1
    var needLayout: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(textLabel)
        addSubview(secondTextLabel)
        self.addConstraint(NSLayoutConstraint(item: textLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 0.5,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textLabel,
                                              attribute: .width,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: self,
                                              attribute: .width,
                                              multiplier: 0.88,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textLabel,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .height,
                                              multiplier: 0.29,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .width,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: self,
                                              attribute: .width,
                                              multiplier: 0.88,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .height,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: self,
                                              attribute: .height,
                                              multiplier: 0.2,
                                              constant: 0))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.anchorPoint = CGPoint(x: 0, y: 0)
        let t = CGAffineTransform(scaleX: scale, y: scale)
        transform = t
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
