//
//  AddAllUserCardtList.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

// MARK: - Save REALM
struct AddAllUserCardtList {
    
    static func add(_ completion: @escaping () -> ()) {
        
        /// Общая информация об поставщике услуг
        var cardsArray     = [UserAllCardsModel]()
        var tempcardsArray = [UserAllCardsModel]()
        var tempCard = UserAllCardsModel()
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let cardList = model.data else { return }
                
                cardList.forEach { card in
                    
                    let cards      = UserAllCardsModel()
                    cards.number             = card.number
                    cards.numberMasked       = card.numberMasked
                    cards.balance            = card.balance ?? 0.0
                    cards.currency           = card.currency
                    cards.productType        = card.productType
                    cards.productName        = card.productName
                    cards.ownerID            = card.ownerID ?? 0
                    cards.accountNumber      = card.accountNumber
                    cards.allowDebit         = card.allowDebit ?? false
                    cards.allowCredit        = card.allowCredit ?? false
                    cards.customName         = card.customName
                    cards.cardID             = card.cardID ?? 0
                    cards.name               = card.name
                    cards.validThru          = card.validThru ?? 0
                    cards.status             = card.status
                    cards.holderName         = card.holderName
                    cards.product            = card.product
                    cards.branch             = card.branch
                    cards.mainField          = card.mainField
                    cards.additionalField    = card.additionalField
                    cards.smallDesign        = card.smallDesign
                    cards.mediumDesign       = card.mediumDesign
                    cards.largeDesign        = card.largeDesign
                    cards.paymentSystemName  = card.paymentSystemName
                    cards.paymentSystemImage = card.paymentSystemImage
                    cards.fontDesignColor    = card.fontDesignColor
                    cards.id                 = card.id ?? 0
                    cards.openDate           = card.openDate ?? 0
                    cards.branchId           = card.branchId ?? 0
                    cards.accountID          = card.accountID ?? 0
                    cards.expireDate         = card.expireDate
                    cards.XLDesign           = card.XLDesign
                    cards.statusPC           = card.statusPC
                    
                    card.background.forEach { color in
                        let colors = UserAllCardsbackgroundModel()
                        colors.color = color
                        cards.background.append(colors)
                    }
                    tempCard = cards
                    tempcardsArray.append(tempCard)
                }
                tempcardsArray.forEach { value in
                    cardsArray.append(value)
                }
//                tempcardsArray.removeAll()
                /// Сохраняем в REALM
                let realm = try? Realm()
                do {
                    let operators = realm?.objects(UserAllCardsModel.self)
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(cardsArray)
                    try realm?.commitWrite()
                    completion()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
