//
//  FeedCurrent1Cell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FeedCurrent6Cell: UITableViewCell {

    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var currencyImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var subsubtitle: UILabel!
    @IBOutlet weak var position1name: UILabel!
    @IBOutlet weak var position1value: UILabel!
    @IBOutlet weak var position2name: UILabel!
    @IBOutlet weak var position2value: UILabel!
    @IBOutlet weak var position3name: UILabel!
    @IBOutlet weak var position3value: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = button.frame.height / 2
        
    }
    
    func animateCurrencyLogo() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.currencyImageViewBottomConstraint.constant += 35
            self.contentView.layoutIfNeeded()
        }, completion: {(_) in
            self.currencyImageViewBottomConstraint.constant = 30
        })
    }
}



