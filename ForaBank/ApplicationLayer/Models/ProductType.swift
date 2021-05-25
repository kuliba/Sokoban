//
//  ProductType.swift
//  ForaBank

import Foundation
import Mapper

enum ProductType: String, Comparable {
//    case allProduct = "ALLPRODUCT"
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
//        case .allProduct:
//            return 4
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
//        case .allProduct:
//            return NSLocalizedString("Все продукты", comment: "")
        }
    }

    //описание продукта
    var commentProduct: String{
        switch self {
        case .card:
            return "Если у Вас нет карты, оформите ее на сайте или в любом офисе банка."
        case .account:
            return "Открытие счета возможно только в отделении банка."
        case .deposit:
            return "Все вклады застрахованы в Системе страхования вкладов. Дополнительная информация по страхованию вкладов здесь."
        case .loan:
            return "АКБ "+"ФОРА-БАНК"+" (АО) предлагает доступные и выгодные для разных клиентских сегментов кредитные продукты."
//        case .allProduct:
//            return "Все продукты"
        }
    }
    
    //ссылки на открытие
    var urlProduct: String{
        switch self {
        case .card:
            return "https://cashback-card.forabank.ru/?metka=mp"
        case .account:
            return "https://www.forabank.ru/lendingi/rko/?from=kprst"
        case .deposit:
            return "https://www.forabank.ru/private/deposits/"
        case .loan:
            return "https://www.forabank.ru/private/credits/"
//        case .allProduct:
//            return "https://cashback-card.forabank.ru/?metka=mp"
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
//        case .allProduct:
//            return NSLocalizedString("Продукты", comment: "")
        }
    }

    var coloredImageName: String {
        switch self {
        case .card:
            return "card-colored"
        case .account:
            return "account-colored"
        case .deposit:
            return "deposit-colored"
        case .loan:
            return "loan-colored"
//        case .allProduct:
//            return "card-colored"
        }
    }
}
