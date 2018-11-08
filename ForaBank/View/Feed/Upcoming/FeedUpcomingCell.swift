//
//  FeedUpcomingCell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedUpcomingCell: UITableViewCell {
    
   @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var position1name: UILabel!
    @IBOutlet weak var position1value: UILabel!
    @IBOutlet weak var position2name: UILabel!
    @IBOutlet weak var position2value: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        button1.layer.cornerRadius = button1.frame.height / 2
        button2.layer.cornerRadius = button2.frame.height / 2
        
        button2.backgroundColor = .clear
        button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.gray.withAlphaComponent(0.25).cgColor
        
    }

}
