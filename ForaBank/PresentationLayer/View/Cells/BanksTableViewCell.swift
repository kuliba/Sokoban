//
//  BanksTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class BanksTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBOutlet weak var defaultBank: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageBank: UIImageView!
    @IBOutlet weak var imageStar: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
