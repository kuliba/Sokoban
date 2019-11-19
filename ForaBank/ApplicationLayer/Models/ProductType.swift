//
//  ProductType.swift
//  ForaBank
//
//  Created by Бойко Владимир on 15.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Mapper

enum ProductType: String, Comparable {
    case card = "CARD"
    case account = "ACCOUNT"
    case deposit = "DEPOSIT"
    case loan = "LOAN"

    private var sortOrder: Int {
        switch self {
        case .card:
            return 0
        case .account:
            return 1
        case .deposit:
            return 2
        case .loan:
            return 3
        }
    }

    static func == (lhs: ProductType, rhs: ProductType) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }

    static func < (lhs: ProductType, rhs: ProductType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    var localizedName: String {
        switch self {
        case .card:
            return NSLocalizedString("Карта", comment: "")
        case .account:
            return NSLocalizedString("Счёт", comment: "")
        case .deposit:
            return NSLocalizedString("Вклад", comment: "")
        case .loan:
            return NSLocalizedString("Кредит", comment: "")
        }
    }

    var localizedListName: String {
        switch self {
        case .card:
            return NSLocalizedString("Карты", comment: "")
        case .account:
            return NSLocalizedString("Счета", comment: "")
        case .deposit:
            return NSLocalizedString("Вклады", comment: "")
        case .loan:
            return NSLocalizedString("Кредиты", comment: "")
        }
    }
}
