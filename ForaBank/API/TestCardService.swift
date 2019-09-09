/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class TestCardService: CardServiceProtocol {
    
    private var cards: [Card] = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
//        var c1 = Card.init(type: .visaGold,
//                           paypass: true,
//                           title: "Visa Gold Cashback",
//                           number: "2345456789079707",
//                           blocked: false,
//                           startDate: f.date(from: "01.08.2016")!,
//                           expirationDate: f.date(from: "01.08.2018")!,
//                           availableBalance: 21_350,
//                           blockedMoney: 0,
//                           updatingDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
//                           tariff: "Классика")
//        var c2 = Card.init(type: .visaPlatinum,
//                           paypass: true,
//                           title: "Visa Platinum Cashback",
//                           number: "5676456789079706",
//                           blocked: false,
//                           startDate: f.date(from: "21.08.2015")!,
//                           expirationDate: f.date(from: "21.08.2018")!,
//                           availableBalance: 19_500,
//                           blockedMoney: 430.50,
//                           updatingDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
//                           tariff: "Классика")
//        var c3 = Card.init(type: .mastercard,
//                           paypass: true,
//                           title: "RIO CARD",
//                           number: "5009456789079705",
//                           blocked: false,
//                           startDate: f.date(from: "11.05.2017")!,
//                           expirationDate: f.date(from: "11.05.2019")!,
//                           availableBalance: 7_500.15,
//                           blockedMoney: 1_230,
//                           updatingDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
//                           tariff: "Классика")
//        var c4 = Card.init(type: .visaDebet,
//                           paypass: true,
//                           title: "Дебетовая",
//                           number: "5676456789079704",
//                           blocked: false,
//                           startDate: f.date(from: "5.05.2015")!,
//                           expirationDate: f.date(from: "5.05.2019")!,
//                           availableBalance: 19_500.15,
//                           blockedMoney: 2_230,
//                           updatingDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
//                           tariff: "Классика")
//        var c5 = Card.init(type: .visaPlatinum,
//                           paypass: false,
//                           title: "Visa Platinum",
//                           number: "5676456789079703",
//                           blocked: true,
//                           startDate: f.date(from: "11.05.2013")!,
//                           expirationDate: f.date(from: "11.05.2017")!,
//                           availableBalance: 0,
//                           blockedMoney: 0,
//                           updatingDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
//                           tariff: "Классика")
//        var c6 = Card.init(type: .visaDebet,
//                           paypass: true,
//                           title: "Дебетовая",
//                           number: "5009456789079702",
//                           blocked: false,
//                           startDate: f.date(from: "11.05.2017")!,
//                           expirationDate: f.date(from: "11.05.2019")!,
//                           availableBalance: 7_500.15,
//                           blockedMoney: 1_230,
//                           updatingDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
//                           tariff: "Классика")
//        return [c1,c2,c3,c4,c5,c6]
        return []
    }()
    
    func getCardList(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Card]?) -> Void) {
        completionHandler(true, cards)
    }
    func blockCard(withNumber num: String, completionHandler: @escaping (Bool) -> Void) {
        for i in 0..<cards.count {
            if cards[i].number == num {
                cards[i].blocked = true
            }
        }
        completionHandler(true)
    }
    
    func getTransactionsStatement(forCardNumber: String, fromDate: Date, toDate: Date, headers: HTTPHeaders, completionHandler: @escaping (Bool, [DatedTransactions]?) -> Void) {
        completionHandler(true, datedTransactions)
    }
    
    private var datedTransactions: [DatedTransactions] = {
        let t11 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                   amount: -14567.07,
                                   currency: "ru_RU",
                                   counterpartName: "METRO Store 1019",
                                   counterpartImageURL: "deposit_history_transaction_metro",
                                   details: "Гипермаркет",
                                   bonuses: 1200)
        let t12 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                   amount: -2000,
                                   currency: "ru_RU",
                                   counterpartName: "PEREKRESTOK 24",
                                   counterpartImageURL: "deposit_history_transaction_perekrestok",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let dt1 = DatedTransactions.init(changeOfBalanse: -16567.07,
                                         currency: "ru_RU",
                                         dateFrom: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                         dateTo: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                         transactions: [t11, t12])
        
        let t21 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                   amount: 2000.50,
                                   currency: "ru_RU",
                                   counterpartName: "Инна Сидорова",
                                   counterpartImageURL: "deposit_history_transaction_sidorova",
                                   details: "За тренировки",
                                   bonuses: 0)
        let t22 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                   amount: -2100.50,
                                   currency: "ru_RU",
                                   counterpartName: "Азбука Вкуса",
                                   counterpartImageURL: "deposit_history_transaction_azbuka",
                                   details: "Супермаркет",
                                   bonuses: 65)
        let t23 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                   amount: 507.07,
                                   currency: "ru_RU",
                                   counterpartName: "Павел Герасимчук",
                                   counterpartImageURL: "deposit_history_transaction_gerasimchuk",
                                   details: "За посиделки, которые были в бане",
                                   bonuses: 0)
        let t24 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                   amount: -2100,
                                   currency: "ru_RU",
                                   counterpartName: "PEREKRESTOK 24",
                                   counterpartImageURL: "deposit_history_transaction_perekrestok",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let t25 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                   amount: -250,
                                   currency: "ru_RU",
                                   counterpartName: "Dyadushka KHO",
                                   counterpartImageURL: "deposit_history_transaction_dyadushkakho",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let dt2 = DatedTransactions.init(changeOfBalanse: -6567.07,
                                         currency: "ru_RU",
                                         dateFrom: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                                         dateTo: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                         transactions: [t21, t22, t23, t24, t25])
        
        let t31 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                                   amount: -14567.07,
                                   currency: "ru_RU",
                                   counterpartName: "METRO Store 1019",
                                   counterpartImageURL: "deposit_history_transaction_metro",
                                   details: "Гипермаркет",
                                   bonuses: 1200)
        let t32 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                                   amount: -2000,
                                   currency: "ru_RU",
                                   counterpartName: "PEREKRESTOK 24",
                                   counterpartImageURL: "deposit_history_transaction_perekrestok",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let dt3 = DatedTransactions.init(changeOfBalanse: -16567.07,
                                         currency: "ru_RU",
                                         dateFrom: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                         dateTo: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                                         transactions: [t31, t32])
        
        let t41 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                   amount: -1050.50,
                                   currency: "ru_RU",
                                   counterpartName: "Pyatorochka Pechatniki",
                                   counterpartImageURL: "deposit_history_transaction_pyaterochka",
                                   details: "Продуктовый магазин",
                                   bonuses: 10)
        let t42 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                   amount: -2100.50,
                                   currency: "ru_RU",
                                   counterpartName: "Азбука Вкуса",
                                   counterpartImageURL: "deposit_history_transaction_azbuka",
                                   details: "Супермаркет",
                                   bonuses: 65)
        let t43 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                   amount: -507.07,
                                   currency: "ru_RU",
                                   counterpartName: "METRO Store 1019",
                                   counterpartImageURL: "deposit_history_transaction_metro",
                                   details: "Гипермаркет",
                                   bonuses: 15)
        let t44 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                   amount: -2000,
                                   currency: "ru_RU",
                                   counterpartName: "PEREKRESTOK 24",
                                   counterpartImageURL: "deposit_history_transaction_perekrestok",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let t45 = Transaction.init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                   amount: -250,
                                   currency: "ru_RU",
                                   counterpartName: "Dyadushka KHO",
                                   counterpartImageURL: "deposit_history_transaction_dyadushkakho",
                                   details: "Гипермаркет",
                                   bonuses: 65)
        let dt4 = DatedTransactions.init(changeOfBalanse: 6567.07,
                                         currency: "ru_RU",
                                         dateFrom: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                                         dateTo: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                                         transactions: [t41, t42, t43, t44, t45])
        return [dt1, dt2, dt3, dt4]
    }()
}
