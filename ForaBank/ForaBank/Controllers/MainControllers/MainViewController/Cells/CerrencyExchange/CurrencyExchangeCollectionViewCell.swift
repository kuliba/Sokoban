//
//  CurrencyExchangeCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

class CurrencyExchangeCollectionViewCell: UICollectionViewCell, SelfConfiguringCell {
    
    
    
    static var reuseId: String = "CurrencyExchangeCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var viewCurrency: UIView!
    
    func configure<U>(with value: U) where U : Hashable {
        layer.cornerRadius = 12
    }
 
    
}
