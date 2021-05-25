//
//  HeaderOperationCollectionReusableView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.06.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class HeaderOperationCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var headerTitile: UILabel!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var allHeaderButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
