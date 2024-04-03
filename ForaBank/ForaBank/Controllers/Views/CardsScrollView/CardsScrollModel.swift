//
//  CardsScrollModel.swift
//  ForaBank
//
//  Created by Mikhail on 28.09.2021.
//

import UIKit

struct CardsScrollModel {
    
    let card: UserAllCardsModel
    var getUIImage: (Md5hash) -> UIImage? = { _ in UIImage() }
    var isChecked: Bool = false

    var cardNumber: String? {
        return card.number
    }
    
    var balance: String {
        var cardBal: Double = card.balance
        if card.productType == ProductType.loan.rawValue {
            cardBal = card.totalAmountDebt
        }
        return cardBal.currencyFormatter(symbol: card.currency ?? "")
    }
    
    var maskedcardNumber: String {
        if card.productType == "DEPOSIT" {
            return "\(card.accountNumber?.suffix(4) ?? "")"
        } else if card.productType == ProductType.loan.rawValue {
            return "\(card.settlementAccount?.suffix(4) ?? "")"
        } else {
            return "\(cardNumber?.suffix(4) ?? "")"
        }
        
    }
    
    var cardName: String? {
        return card.customName ?? card.mainField
    }
    
    var logoImage: UIImage {
        if card.productType == "ACCOUNT" {
            let label = UILabel(text: card.currency?.getSymbol() ?? "",
                                font: .systemFont(ofSize: 10),
                                color: .white)
            label.frame = CGRect(x: 0, y: 0, width: 13, height: 13)
            label.textAlignment = .center
            label.layer.cornerRadius = 3
            label.layer.borderColor = UIColor.white.cgColor
            return UIImage.imageWithLabel(label: label)
        } else {
            return UIImage()
        }
    }
    
    var colorText: UIColor? {
        let color = hexStringToUIColor(hex: card.fontDesignColor ?? "FFFFFF")
        return color
    }
    
    var backgroundImage: UIImage {
        if let md5Hash = card.mediumDesignMd5Hash {
            return getUIImage(md5Hash) ?? UIImage()
        } else {
            return UIImage()
        }
    }
    
    init(
        card: UserAllCardsModel,
        getUIImage: @escaping (Md5hash) -> UIImage?
    ) {
        self.card = card
        self.getUIImage = getUIImage
    }
    
    func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

