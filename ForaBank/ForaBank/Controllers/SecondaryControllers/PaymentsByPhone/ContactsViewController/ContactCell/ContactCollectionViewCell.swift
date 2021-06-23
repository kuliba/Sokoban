//
//  ContactCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import Contacts

class ContactCollectionViewCell: UICollectionViewCell{
    
    static var reuseId: String = "ContactCollectionViewCell"

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
