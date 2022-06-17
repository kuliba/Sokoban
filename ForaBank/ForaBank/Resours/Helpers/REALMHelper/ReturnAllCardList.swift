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
        
        Model.shared.products.value.values.flatMap({ $0 }).map{ $0.userAllProducts() }
    }
}
