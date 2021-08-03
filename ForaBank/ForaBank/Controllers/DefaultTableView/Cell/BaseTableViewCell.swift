//
//  BaseTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 03.08.2021.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCompany: UILabel!
    @IBOutlet weak var kppLabel: UILabel!
    static let reuseId = "BaseTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
