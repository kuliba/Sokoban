import UIKit


class InternetTVConfirmViewModel {
    var type: PaymentType
    var template: PaymentTemplateData?
    var fullName: String? = ""
    var templateButtonViewModel: TemplateButtonViewModel?
    var cardFromRealm: UserAllCardsModel? {
        didSet {
            guard let cardFrom = cardFromRealm else { return }
            if cardFrom.productType == "CARD" {
                cardFromCardId = "\(cardFrom.id)"
                cardFromAccountId = ""
            } else if cardFrom.productType == "ACCOUNT" {
                cardFromAccountId = "\(cardFrom.id)"
                cardFromCardId = ""
            }
        }
    }
    var cardFrom: UserAllCardsModel? {
        didSet {
            guard let cardFrom = cardFrom else { return }
            if cardFrom.productType == "CARD" {
                //if let cardID = cardFrom.id {
                    cardFromCardId = "\(cardFrom.id)"
                    cardFromAccountId = ""
                //}
            } else if cardFrom.productType == "ACCOUNT" {
                //if let accountID = cardFrom.id {
                    cardFromAccountId = "\(cardFrom.id)"
                    cardFromCardId = ""
                //}
            }
        }
    }
    var cardFromCardId = ""
    var cardFromAccountId = ""
    var cardToRealm: UserAllCardsModel? {
        didSet {
            guard let cardTo = cardToRealm else { return }
            customCardTo = nil
            if cardTo.productType == "CARD" {
                cardToCardId = "\(cardTo.id)"
                cardToAccountId = ""
            } else if cardTo.productType == "ACCOUNT" {
                cardToAccountId = "\(cardTo.id)"
                cardToCardId = ""
            }
        }
    }
    var cardTo: GetProductListDatum? {
        didSet {
            guard let cardTo = cardTo else { return }
            customCardTo = nil
            if cardTo.productType == "CARD" {
                if let cardID = cardTo.id {
                    cardToCardId = "\(cardID)"
                    cardToAccountId = ""
                }
            } else if cardTo.productType == "ACCOUNT" {
                if let accountID = cardTo.id {
                    cardToAccountId = "\(accountID)"
                    cardToCardId = ""
                }
            }
        }
    }
    var customCardTo: CastomCardViewModel? {
        didSet {
            guard let cardTo = customCardTo else { return }
            self.cardTo = nil
            cardToCardNumber = cardTo.cardNumber
            cardToCustomName = cardTo.cardName ?? ""
            if cardTo.cardId != nil {
                cardToCardId = "\(cardTo.cardId ?? 0)"
                cardToCardNumber = ""
            }
        }
    }
    var cardToCardId = ""
    var cardToCardNumber = ""
    var cardToAccountId = ""
    var cardToCustomName = ""
    var payToCompany = false
    var sumTransaction: String = ""
    var taxTransaction: String = ""
    var statusIsSuccess: Bool = false
    
    init(type: PaymentType) {
        self.type = type
    }
    
    enum PaymentType {
        case internetTV
        case gkh
        case transport
    }
    
}

extension InternetTVConfirmViewModel {
    
    enum TemplateButtonViewModel {
        
        case template(PaymentTemplateData.ID)
        case sfp(name: String, paymentOperationDetailId: Int)
    }
}
