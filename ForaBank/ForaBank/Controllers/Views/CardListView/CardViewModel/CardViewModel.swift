//
//  CardViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import UIKit


struct CardViewModel {
    
    let card: GetProductListDatum
    
    var cardNumber: String? {
        return card.number
    }
    
    var balance: String {
        let cardBal: Double = card.balance ?? 0
        return cardBal.currencyFormatter(symbol: card.currency ?? "")
    }
    
    var fullBalance: String {
        let cardBal: Double = card.balance ?? 0
        return cardBal.fullCurrencyFormatter(symbol: card.currency ?? "")
    }
    
    
    var maskedcardNumber: String {
        if card.productType == "DEPOSIT" {
            return "• \(card.accountNumber?.suffix(4) ?? "")"
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
//            label.layer.borderWidth = 1.25
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
        if !(card.mediumDesign?.isEmpty ?? true)  {
            return card.mediumDesign?.convertSVGStringToImage() ?? UIImage()
        } else {
            return UIImage()
        }
    }
    
    init(card: GetProductListDatum) {
        self.card = card
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



struct CardViewModelFromRealm {
    
    let card: UserAllCardsModel
    
    var cardNumber: String? {
        return card.number
    }
    
    var balance: String {
        let cardBal: Double = card.balance
        return cardBal.currencyFormatter(symbol: card.currency ?? "")
    }
    
    var fullBalance: String {
        let cardBal: Double = card.balance
        return cardBal.fullCurrencyFormatter(symbol: card.currency ?? "")
    }
    
    var maskedcardNumber: String {
        if card.productType == "DEPOSIT" {
            return "\(card.accountNumber?.suffix(4) ?? "")"
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
//            label.layer.borderWidth = 1.25
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
        if !(card.mediumDesign?.isEmpty ?? true)  {
            return card.mediumDesign?.convertSVGStringToImage() ?? UIImage()
        } else {
            return UIImage()
        }
    }
    
    init(card: UserAllCardsModel) {
        self.card = card
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
