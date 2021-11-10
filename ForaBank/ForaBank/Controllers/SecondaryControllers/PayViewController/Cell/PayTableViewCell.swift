//
//  PayTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 17.09.2021.
//

import UIKit

class PayTableViewCell: UITableViewCell {

    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageButton.layer.masksToBounds = false
        imageButton.layer.cornerRadius = imageButton.frame.height/2
        imageButton.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
}
