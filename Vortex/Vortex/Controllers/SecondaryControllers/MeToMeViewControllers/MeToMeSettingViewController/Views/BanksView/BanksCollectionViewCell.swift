//
//  BanksCollectionViewCell.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 28.06.2022.
//

import UIKit
import SwiftUI

class BanksCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var itemView: UIView!
    
    static var refCell = "BanksCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemView.layer.cornerRadius = 16
        itemView.backgroundColor = Color.buttonSecondary.uiColor()
    }
    
    func configure(with bank: String?, and indexPath: IndexPath) {

        bankName.text = bank ?? ""
    }
    
}






