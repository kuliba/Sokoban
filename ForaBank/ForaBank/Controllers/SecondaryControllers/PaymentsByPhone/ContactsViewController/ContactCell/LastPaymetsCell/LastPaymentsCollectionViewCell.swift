//
//  LastPaymentsCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

class LastPaymentsCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String = "LastPaymentsCollectionViewCell"

    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
