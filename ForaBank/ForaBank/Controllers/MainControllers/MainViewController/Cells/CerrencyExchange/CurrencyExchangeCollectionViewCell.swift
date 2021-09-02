//
//  CurrencyExchangeCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

class CurrencyExchangeCollectionViewCell: UICollectionViewCell, SelfConfiguringCell {
    
    func configure<U>(with value: U) where U : Hashable {
        
    }
    
    
    static var reuseId: String = "CurrencyExchangeCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
