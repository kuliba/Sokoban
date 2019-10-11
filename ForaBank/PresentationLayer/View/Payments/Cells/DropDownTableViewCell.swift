//
//  DropDownTableViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var arrowsImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    @IBOutlet weak var leadingToArrowConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingToSuperviewConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    internal func setupLayout(withPickerItem pickerItem: IPickerItem, isDroppable: Bool) {
        leadingToArrowConstraint.isActive = isDroppable
        leadingToSuperviewConstraint.isActive = !isDroppable
        arrowsImageView.isHidden = !isDroppable

        titleLabel.text = pickerItem.title
        numberLabel.text = pickerItem.subTitle
        sumLabel.text = String(pickerItem.value)

        updateConstraints()
    }
}
