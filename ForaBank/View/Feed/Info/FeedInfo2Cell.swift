//
//  FeedInfo2Cell.swift
//  ForaBank
//
//  Created by Ilya Masalov on 12/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedInfo2Cell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        button.layer.cornerRadius = button.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
