//
//  CustomCardListCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.07.2021.
//

import UIKit

class AllCardListCell: UITableViewCell {
    
    @IBOutlet var xibCell: UITableViewCell!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
