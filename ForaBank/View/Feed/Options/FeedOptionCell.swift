//
//  FeedOptionCell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 10/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedOptionCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!    

    @IBOutlet weak var changePinCode: UISwitch!
    @IBAction func changePinCode(_ sender: Any) {
        if let s = sender as? UISwitch,
            s.isOn == true {
<<<<<<< HEAD
      
=======
>>>>>>> origin/Refactoring
        }
    }
}
