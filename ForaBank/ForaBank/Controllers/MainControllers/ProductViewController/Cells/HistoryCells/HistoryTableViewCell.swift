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
    
    var operation: GetCardStatementDatum?
    var accountOperation: GetAccountStatementDatum?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        logoImageView.image = UIImage()
        logoImageView.isHidden = false
        logoImageView.layer.masksToBounds = false
        logoImageView.layer.cornerRadius = logoImageView.frame.height/2
        logoImageView.clipsToBounds = true
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(currency: String){
        if accountOperation != nil {
            titleLable.text = operation?.comment
            guard let sum = operation?.amount else {
                return
            }
            if accountOperation?.operationType == "DEBIT"{
                amountLabel.textColor = UIColor(hexString: "1C1C1C")
                logoImageView.backgroundColor = .red
                amountLabel.text = "-\(Double(sum).currencyFormatter(symbol: currency))"
            } else {
                logoImageView.backgroundColor = .green
                amountLabel.textColor = UIColor(hexString: "22C183")
                amountLabel.text = "+\(Double(sum).currencyFormatter(symbol: currency))"
            }
        } else {
            if operation?.type == "OUTSIDE"{
                if operation?.merchantNameRus != nil{
                    titleLable.text = operation?.merchantNameRus
                } else {
                    titleLable.text = operation?.merchantName
                }
                subTitleLabel.isHidden = false
                subTitleLabel.text = operation?.groupName
                logoImageView.image = operation?.svgImage?.convertSVGStringToImage()
                logoImageView.alpha = 1
            } else {
                titleLable.text = operation?.comment
                guard let sum = operation?.amount else {
                    return
                }
                if operation?.operationType == "DEBIT"{
                    logoImageView.backgroundColor = .red
                    logoImageView.alpha = 0.3
                    amountLabel.textColor = UIColor(hexString: "1C1C1C")
                    amountLabel.text = "-\(Double(sum).currencyFormatter(symbol: currency))"
                } else {
                    logoImageView.backgroundColor = .green
                    logoImageView.alpha = 0.3
                    amountLabel.textColor = UIColor(hexString: "22C183")
                    amountLabel.text = "+\(Double(sum).currencyFormatter(symbol: currency))"
                }
            }
        }
        
    }
    
}
