//
//  ReturnAllCardList.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.09.2021.
//

import Foundation
import RealmSwift

/// Получаем из  REALM  карты пользователя
struct ReturnAllCardList {
    
    static func cards() ->  [UserAllCardsModel] {

        var products: [UserAllCardsModel] = []
        let types: [ProductType] = [.card, .account, .deposit, .loan]
        let clientId = Model.shared.clientInfo.value?.id
        types.forEach { type in
            
            products.append(contentsOf: Model.shared.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }
        
        products = products.filter({$0.ownerID == clientId})
        return products
    }
}
