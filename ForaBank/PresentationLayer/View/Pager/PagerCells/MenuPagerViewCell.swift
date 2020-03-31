//
//  MenuPagerViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 02/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView

class MenuPagerViewCell: FSPagerViewCell, IConfigurableCell {

    weak var delegate: ConfigurableCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(provider: ICellProvider?, delegate: ConfigurableCellDelegate) {
        guard provider != nil else {
            titleLabel.text = "Выбрать из контактов"
            return
        }
        //        messageLabel.text = message
    }
}
