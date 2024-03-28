//
//  CurrencyExchangeCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

class CurrencyExchangeCollectionViewCell: UICollectionViewCell, SelfConfiguringCell {
    
    
    @IBOutlet weak var rateSellEuro: UILabel!
    
    @IBOutlet weak var rateBuyEuro: UILabel!
    
    @IBOutlet weak var rateSellUSD: UILabel!
    
    @IBOutlet weak var rateBuyUSD: UILabel!
    
    static var reuseId: String = "CurrencyExchangeCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10

    }
    @IBOutlet weak var viewCurrency: UIView!
    
    func configure<U>(with value: U, getUImage: @escaping (Md5hash) -> UIImage?) where U : Hashable {
        self.layer.cornerRadius = 10

    }
 
    
}
