//
//  PushHistoryCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import UIKit

class PushHistoryCell: UITableViewCell {
    
    @IBOutlet weak var pushImage: UIImageView!
    @IBOutlet weak var pushTitle: UILabel!
    @IBOutlet weak var pushSubTitle: UILabel!
    @IBOutlet weak var pushTimeLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
