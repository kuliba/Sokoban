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
        l.adjustsFontForContentSizeCategory = true
        l.minimumScaleFactor = 0.5
//        l.clipsToBounds = false
//        l.translatesAutoresizingMaskIntoConstraints = false
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
        l.adjustsFontForContentSizeCategory = true
        l.font = UIFont.systemFont(ofSize: 18)
        l.minimumScaleFactor = 0.2
        //        l.translatesAutoresizingMaskIntoConstraints = false
//        l.clipsToBounds = false
        return l
    }()
    
    
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
        self.contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        print(textLabel.text)
        textLabel.frame = CGRect(x: frame.width*0.06,
                                 y: frame.height*0.25,
                                 width: frame.width*0.88,
                                 height: frame.height*0.3)
        secondTextLabel.frame = CGRect(x: frame.width*0.07,
                                       y: frame.height*0.55,
                                       width: frame.width*0.86,
                                       height: frame.height*0.2)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
