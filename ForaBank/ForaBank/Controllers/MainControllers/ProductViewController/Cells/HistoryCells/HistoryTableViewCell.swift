//
//  HistoryTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 14.09.2021.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var operation: GetCardStatementDataClass?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(){
        titleLable.text = operation?.comment
        guard let sum = operation?.amount else {
            return
        }
        if operation?.operationType == "DEBIT"{
            amountLabel.textColor = UIColor(hexString: "1C1C1C")
            amountLabel.text = "-\(sum)"
        } else {
            amountLabel.textColor = UIColor(hexString: "22C183")
            amountLabel.text = "+\(sum)"
        }
    }
    
}
