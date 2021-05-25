//
//  OperationsListCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class OperationsListCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
//        label.sizeToFit()
        label.numberOfLines = 0
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
}
