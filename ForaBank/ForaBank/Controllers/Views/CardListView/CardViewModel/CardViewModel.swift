//
//  CardViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import UIKit


struct CardViewModel {
    
    let card: Datum
    
    var cardNumber: String? {
        return card.original?.number
    }
    
    var balance: String {
        let cardBal: Double = card.original?.balance ?? 0
        return cardBal.currencyFormatter()
    }
    
    var maskedcardNumber: String {
        return "  *\(cardNumber?.suffix(4) ?? "")"
    }
    
    var logoImage: UIImage {
        let firstSimb = cardNumber?.first
        switch firstSimb {
        case "1":
            return #imageLiteral(resourceName: "mir-colored")
        case "4":
            return #imageLiteral(resourceName: "card_visa_logo")
        case "5":
            return #imageLiteral(resourceName: "card_mastercard_logo")
        default:
            return UIImage()
        }
    }
    
    init(card: Datum) {
        self.card = card
    }
    
}

