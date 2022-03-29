//
//  HistoryTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 14.09.2021.
//

import UIKit
import SkeletonView

class HistoryTableViewCell: UITableViewCell {
    
    static let identifier = "HistoryTableViewCell"
    
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var operation: GetCardStatementDatum?
    var accountOperation: GetAccountStatementDatum?
    var depositOperation: GetDepositStatementDatum?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
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
    
    private func setupUI() {
        titleLable.text = ""
        amountLabel.text = ""
        subTitleLabel.text = ""
        logoImageView.layer.cornerRadius = logoImageView.bounds.height / 2
        logoImageView.clipsToBounds = true
    }
    
    func configure(currency: String){
        
        if operation != nil{
            switch operation?.type {
            case "OUTSIDE":
                logoImageView.alpha = 0.3
                if operation?.merchantNameRus != nil{
                    titleLable.text = operation?.merchantNameRus
                } else {
                    titleLable.text = operation?.merchantName
                }
                
                if operation?.merchantNameRus == ""{
                    titleLable.text = operation?.comment
                }
                
                
                if operation?.groupName != nil{
                    subTitleLabel.isHidden = false
                    subTitleLabel.text = operation?.groupName
                } else {
                    subTitleLabel.isHidden = true
                }
                
                if operation?.operationType == "DEBIT"{
                    
                    logoImageView.backgroundColor = .red
                    
                } else if operation?.operationType == "CREDIT"{
                    
                    logoImageView.backgroundColor = .green
                    
                }
                
                if operation?.svgImage != nil{
                    logoImageView.image = operation?.svgImage?.convertSVGStringToImage()
                    logoImageView.backgroundColor = .clear
                    logoImageView.alpha = 1
                }
                
                if operation?.operationType == "DEBIT"{
                    amountLabel.textColor = UIColor(hexString: "1C1C1C")
                    amountLabel.text = "-\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    amountLabel.isHidden = false
                } else if operation?.operationType == "CREDIT" {
                    amountLabel.textColor = UIColor(hexString: "22C183")
                    amountLabel.text = "+\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    amountLabel.isHidden = false
                } else {
                    amountLabel.isHidden = true
                }
                
            case "INSIDE":
                logoImageView.alpha = 0.3
                titleLable.text = operation?.merchantNameRus
                
                if operation?.merchantNameRus != nil{
                    titleLable.text = operation?.merchantNameRus
                } else {
                    titleLable.text = operation?.merchantName
                }
                
                subTitleLabel.isHidden = true
                
                if operation?.merchantNameRus == ""{
                    titleLable.text = operation?.comment
                }
                
                if operation?.groupName != nil{
                    subTitleLabel.isHidden = false
                    subTitleLabel.text = operation?.groupName
                } else {
                    subTitleLabel.isHidden = true
                }
                
                
                if operation?.operationType == "DEBIT"{
                    
                    logoImageView.backgroundColor = .red
                    
                } else if operation?.operationType == "CREDIT"{
                    
                    logoImageView.backgroundColor = .green
                    
                }
                
                if operation?.svgImage != nil{
                    logoImageView.image = operation?.svgImage?.convertSVGStringToImage()
                    logoImageView.backgroundColor = .clear
                    logoImageView.alpha = 1
                }
                
                
                if operation?.operationType == "DEBIT"{
                    amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        amountLabel.text = "-\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    amountLabel.isHidden = false
                } else if operation?.operationType == "CREDIT" {
                    amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    amountLabel.isHidden = false
                } else {
                    amountLabel.isHidden = true
                }
            case .none:
                titleLable.text = operation?.comment
                if operation?.operationType == "DEBIT"{
                    amountLabel.textColor = UIColor(hexString: "1C1C1C")
                    logoImageView.backgroundColor = .red
                        amountLabel.text = "-\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                } else if operation?.operationType == "CREDIT" {
                    amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(operation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                }
            case .some(_):
                print("some")
            }
        }
        
        if accountOperation != nil{
            if accountOperation != nil{
                switch accountOperation?.type {
                case "OUTSIDE":
                    logoImageView.alpha = 0.3
                    if accountOperation?.merchantNameRus != nil{
                        titleLable.text = accountOperation?.merchantNameRus
                    } else {
                        titleLable.text = accountOperation?.merchantName
                    }
                    
                    if accountOperation?.merchantNameRus == ""{
                        titleLable.text = accountOperation?.comment
                    }
                    
                    
                    if accountOperation?.groupName != nil{
                        subTitleLabel.isHidden = false
                        subTitleLabel.text = accountOperation?.groupName
                    } else {
                        subTitleLabel.isHidden = true
                    }
                    
                    if accountOperation?.operationType == "DEBIT"{
                        
                        logoImageView.backgroundColor = .red
                        
                    } else if accountOperation?.operationType == "CREDIT"{
                        
                        logoImageView.backgroundColor = .green
                        
                    }
                    
                    if accountOperation?.svgImage != nil{
                        logoImageView.image = accountOperation?.svgImage?.convertSVGStringToImage()
                        logoImageView.backgroundColor = .clear
                        logoImageView.alpha = 1
                    }
                    
                    if accountOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                            amountLabel.text = "-\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else if accountOperation?.operationType == "CREDIT" {
                        amountLabel.textColor = UIColor(hexString: "22C183")
                            amountLabel.text = "+\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else {
                        amountLabel.isHidden = true
                    }
                    
                case "INSIDE":
                    logoImageView.alpha = 0.3
                    titleLable.text = accountOperation?.merchantNameRus
                    
                    if accountOperation?.merchantNameRus != nil{
                        titleLable.text = accountOperation?.merchantNameRus
                    } else {
                        titleLable.text = accountOperation?.merchantName
                    }
                    
                    subTitleLabel.isHidden = true

                    if accountOperation?.merchantNameRus == ""{
                        titleLable.text = accountOperation?.comment
                    }
                    
                    if accountOperation?.groupName != nil{
                        subTitleLabel.isHidden = false
                        subTitleLabel.text = accountOperation?.groupName
                    } else {
                        subTitleLabel.isHidden = true
                    }
                    
                    
                    if accountOperation?.operationType == "DEBIT"{
                        
                        logoImageView.backgroundColor = .red
                        
                    } else if accountOperation?.operationType == "CREDIT"{
                        
                        logoImageView.backgroundColor = .green
                        
                    }
                    
                    if accountOperation?.svgImage != nil{
                        logoImageView.image = accountOperation?.svgImage?.convertSVGStringToImage()
                        logoImageView.backgroundColor = .clear
                        logoImageView.alpha = 1
                    }
                    
                    if accountOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                            amountLabel.text = "-\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else if accountOperation?.operationType == "CREDIT" {
                        amountLabel.textColor = UIColor(hexString: "22C183")
                            amountLabel.text = "+\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else {
                        amountLabel.isHidden = true
                    }
                case .none:
                    titleLable.text = accountOperation?.comment
                    //                    guard let sum = accountOperation?.amount else {
                    //                        return
                    //                    }
                    if accountOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        logoImageView.backgroundColor = .red
                        amountLabel.text = "-\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    } else {
                        logoImageView.backgroundColor = .green
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    }
                case .some(_):
                    titleLable.text = accountOperation?.comment
                    //                    guard let sum = accountOperation?.amount else {
                    //                        return
                    //                    }
                    if accountOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        logoImageView.backgroundColor = .red
                        amountLabel.text = "-\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    } else {
                        logoImageView.backgroundColor = .green
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(accountOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    }
                }
            }
        }
        
        if depositOperation != nil{
            if depositOperation != nil{
                switch depositOperation?.type {
                case "OUTSIDE":
                    logoImageView.alpha = 0.3
                    if depositOperation?.merchantNameRus != nil{
                        subTitleLabel.text = depositOperation?.merchantNameRus
                    } else {
                        subTitleLabel.text = accountOperation?.merchantName
                    }
                    
                    if depositOperation?.merchantNameRus == ""{
                        subTitleLabel.text = accountOperation?.comment
                    }
                    
                    
                    if depositOperation?.groupName != nil{
                        titleLable.isHidden = false
                        titleLable.text = depositOperation?.groupName
                    } else {
                        titleLable.isHidden = true
                    }
                    
                    if depositOperation?.operationType == "DEBIT"{
                        
                        logoImageView.backgroundColor = .red
                        
                    } else if depositOperation?.operationType == "CREDIT"{
                        
                        logoImageView.backgroundColor = .green
                        
                    }
                    
                    if depositOperation?.svgImage != nil{
                        logoImageView.image = depositOperation?.svgImage?.convertSVGStringToImage()
                        logoImageView.backgroundColor = .clear
                        logoImageView.alpha = 1
                    }
                    
                    if depositOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        amountLabel.text = "-\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else if depositOperation?.operationType == "CREDIT"{
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    }  else {
                        amountLabel.isHidden = true
                    }
                    
                case "INSIDE":
                    //                    logoImageView.alpha = 0.3
                    //                    subTitleLabel.text = depositOperation?.merchantNameRus
                    
                    if depositOperation?.groupName != nil{
                        subTitleLabel.text = depositOperation?.groupName
                        subTitleLabel.isHidden = false
                    } else {
                        subTitleLabel.text = depositOperation?.groupName
                        subTitleLabel.isHidden = true
                    }
                    
                    //            logoImageView.image = UIImage()
                    //            logoImageView.image = operation?.svgImage?.convertSVGStringToImage()
                    if depositOperation?.merchantNameRus == ""{
                        subTitleLabel.text = depositOperation?.comment
                    }
                    
                    //                    guard let sum = depositOperation?.amount else {
                    //                        return
                    //                    }
                    
                    if depositOperation?.merchantNameRus != nil{
                        titleLable.isHidden = false
                        titleLable.text = depositOperation?.merchantNameRus
                    } else {
                        titleLable.isHidden = true
                    }
                    
                    
                    
                    if depositOperation?.svgImage != nil{
                        logoImageView.image = depositOperation?.svgImage?.convertSVGStringToImage()
                        logoImageView.backgroundColor = .clear
                        logoImageView.alpha = 1
                    } else {
                        logoImageView.alpha = 0.3
                        if depositOperation?.operationType == "DEBIT"{
                            
                            logoImageView.backgroundColor = .red
                            
                        } else if depositOperation?.operationType == "CREDIT"{
                            
                            logoImageView.backgroundColor = .green
                            
                        }
                    }
                    
                    if depositOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        amountLabel.text = "-\(Double( depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else if depositOperation?.operationType == "CREDIT" {
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double( depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                        amountLabel.isHidden = false
                    } else {
                        amountLabel.isHidden = true
                    }
                case .none:
                    titleLable.text = depositOperation?.comment
                    //                    guard let sum = depositOperation?.amount else {
                    //                        return
                    //                    }
                    if depositOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        logoImageView.backgroundColor = .red
                        amountLabel.text = "-\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    } else {
                        logoImageView.backgroundColor = .green
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    }
                case .some(_):
                    titleLable.text = operation?.comment
                    //                    guard let sum = operation?.amount else {
                    //                        return
                    //                    }
                    if depositOperation?.operationType == "DEBIT"{
                        amountLabel.textColor = UIColor(hexString: "1C1C1C")
                        logoImageView.backgroundColor = .red
                        amountLabel.text = "-\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    } else {
                        logoImageView.backgroundColor = .green
                        amountLabel.textColor = UIColor(hexString: "22C183")
                        amountLabel.text = "+\(Double(depositOperation?.amount ?? 0.0).currencyFormatter(symbol: currency))"
                    }
                }
            }
        }
        
        
        
        
        
    }
    
    
    
}
