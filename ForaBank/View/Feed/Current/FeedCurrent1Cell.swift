//
//  FeedCurrent1Cell.swift
//  ForaBank
//
//  Created by Ilya Masalov on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedCurrent1Cell: UITableViewCell {

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
}


