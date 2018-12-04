//
//  BubbleDetailedStatsView.swift
//  ForaBank
//
//  Created by Sergey on 04/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class BubbleDetailedStatsView: UIView {

    var image: UIImage! {
        didSet {
            print(image.size)
            imageView.image = image
            imageWidthConstraint?.constant = image.size.width
            imageHeightConstraint?.constant = image.size.height
//            layoutSubviews()
        }
    }
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?

    let textLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
//                l.backgroundColor = .black
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
//                l.backgroundColor = .black
        l.textAlignment = .center
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let imageView: UIImageView = {
        let i = UIImageView()
//        i.backgroundColor = .blue
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    var scale: CGFloat = 1
    var needLayout: Bool = true
    
    convenience init(withLabels: Bool) {
        self.init()
        if withLabels {
            initWithLabels()
        } else {
            initWithoutLabels()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }
    
    private func initWithLabels() {
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(secondTextLabel)
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 0.5,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        imageWidthConstraint = NSLayoutConstraint(item: imageView,
                                                  attribute: .width,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 50)
        self.addConstraint(imageWidthConstraint!)
        imageHeightConstraint = NSLayoutConstraint(item: imageView,
                                                   attribute: .height,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1,
                                                   constant: 50)
        self.addConstraint(imageHeightConstraint!)
        self.addConstraint(NSLayoutConstraint(item: textLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: imageView,
                                              attribute: .bottom,
                                              multiplier: 1,
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
                                              multiplier: 0.2,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textLabel,
                                              attribute: .bottom,
                                              multiplier: 1,
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
                                              multiplier: 0.8,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: secondTextLabel,
                                              attribute: .height,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: self,
                                              attribute: .height,
                                              multiplier: 0.2,
                                              constant: 0))
    }
    
    private func initWithoutLabels() {
        addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        imageWidthConstraint = NSLayoutConstraint(item: imageView,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1,
                                                   constant: 50)
        self.addConstraint(imageWidthConstraint!)
        imageHeightConstraint = NSLayoutConstraint(item: imageView,
                                                   attribute: .height,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1,
                                                   constant: 50)
        self.addConstraint(imageHeightConstraint!)
    }
    
    override func layoutSubviews() {
//        print("!!BubbleDetailedStatsView layoutSubviews")
        super.layoutSubviews()
//        layer.anchorPoint = CGPoint(x: 0, y: 0)
//        let t = CGAffineTransform(scaleX: scale, y: scale)
//        transform = t
//        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
