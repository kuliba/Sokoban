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
    var product: GetProductListDatum?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        rightButton.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        if nameCellLabel.text == "Номер карты"{
            rightButton.isHidden = false
            rightButton.addTarget(self, action: #selector(unmaskNumber), for: .touchUpInside)
        } else if nameCellLabel.text == "Корреспондентский счет"{
            rightButton.setImage(UIImage(named: "copy"), for: .normal)
            rightButton.isHidden = false
            rightButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(copyValuePressed)))

        }


    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func copyValuePressed() {
        UIPasteboard.general.string = titleLabel.text
    }
    @objc func unmaskNumber() {
        titleLabel.text = product?.number
    }
    
}
