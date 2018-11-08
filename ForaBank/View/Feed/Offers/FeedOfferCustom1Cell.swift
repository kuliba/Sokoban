//
//  FeedOfferCustom1Cell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 08/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedOfferCustom1Cell: UITableViewCell {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = button.frame.height / 2
        bgImageView.clipsToBounds = true
        
        
    }
    
}
