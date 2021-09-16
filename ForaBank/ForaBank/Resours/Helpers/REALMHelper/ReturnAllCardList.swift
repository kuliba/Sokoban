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
    
    static func cards() ->  [UserAllCardsModel]{
        let realm = try? Realm()
        let cards = realm?.objects(UserAllCardsModel.self)
        var cardsArray = [UserAllCardsModel]()
        cards?.forEach { card in
            cardsArray.append(card)
        }
        return cardsArray
    }
}
