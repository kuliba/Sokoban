//
//  CardCVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 19.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class CardCVC: UICollectionViewCell {
    @IBOutlet weak var nameCard: UILabel!
    @IBOutlet weak var numberCard: UILabel!
    @IBOutlet weak var amountCard: UILabel!
}

class RateCVC: UICollectionViewCell{
    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var buyCurrency: UILabel!
    @IBOutlet weak var saleCurrency: UILabel!
    @IBOutlet weak var cbCarrency: UILabel!
    
}

class ActionCell: UITableViewCell{
    @IBOutlet weak var nameCell: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.nameCell.textColor = .black
        self.selectionStyle = .none
    }
}
