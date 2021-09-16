//
//  RequisitsTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 16.09.2021.
//

import UIKit

class RequisitsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var nameCellLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
