//
//  LastPaymentsCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

class LastPaymentsCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String = "LastPaymentsCollectionViewCell"
    
    var contacts = [PhoneContact]()
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
        
    }

}
