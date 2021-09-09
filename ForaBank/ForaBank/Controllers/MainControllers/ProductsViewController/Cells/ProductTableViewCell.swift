//
//  ProductTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 30.08.2021.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    static let identifier = "ProductTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "ProductTableViewCell", bundle: nil)
    }

    @IBOutlet weak var coverpProductImage: UIImageView!
    @IBOutlet weak var cardTypeImage: UIImageView!
    @IBOutlet weak var titleProductLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var numberProductLabel: UILabel!
    @IBOutlet weak var typeOfProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func configure(product)
    
}
