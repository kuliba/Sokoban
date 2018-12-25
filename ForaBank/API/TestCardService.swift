//
//  TestCardService.swift
//  ForaBank
//
//  Created by Sergey on 17/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestCardService: CardServiceProtocol {
    
    
    private var cards: [Card] = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        var c1 = Card.init(type: .visaGold,
                           paypass: true,
                           title: "Visa Gold Cashback",
                           number: "2345 4567 8907 9707",
                           blocked: false,
                           startDate: f.date(from: "01.08.2016")!,
                           expirationDate: f.date(from: "01.08.2018")!,
                           availableBalance: 21_350,
                           blockedMoney: 0,
                           updatingDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                           tariff: "Классика")
        var c2 = Card.init(type: .visaPlatinum,
                           paypass: true,
                           title: "Visa Platinum Cashback",
                           number: "5676 4567 8907 9706",
                           blocked: false,
                           startDate: f.date(from: "21.08.2015")!,
                           expirationDate: f.date(from: "21.08.2018")!,
                           availableBalance: 19_500,
                           blockedMoney: 430.50,
                           updatingDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                           tariff: "Классика")
        var c3 = Card.init(type: .mastercard,
                           paypass: true,
                           title: "RIO CARD",
                           number: "5009 4567 8907 9705",
                           blocked: false,
                           startDate: f.date(from: "11.05.2017")!,
                           expirationDate: f.date(from: "11.05.2019")!,
                           availableBalance: 7_500.15,
                           blockedMoney: 1_230,
                           updatingDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                           tariff: "Классика")
        var c4 = Card.init(type: .visaDebet,
                           paypass: true,
                           title: "Дебетовая",
                           number: "5676 4567 8907 9704",
                           blocked: false,
                           startDate: f.date(from: "5.05.2015")!,
                           expirationDate: f.date(from: "5.05.2019")!,
                           availableBalance: 19_500.15,
                           blockedMoney: 2_230,
                           updatingDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                           tariff: "Классика")
        var c5 = Card.init(type: .visaPlatinum,
                           paypass: false,
                           title: "Visa Platinum",
                           number: "5676 4567 8907 9703",
                           blocked: true,
                           startDate: f.date(from: "11.05.2013")!,
                           expirationDate: f.date(from: "11.05.2017")!,
                           availableBalance: 0,
                           blockedMoney: 0,
                           updatingDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                           tariff: "Классика")
        var c6 = Card.init(type: .visaDebet,
                           paypass: true,
                           title: "Дебетовая",
                           number: "5009 4567 8907 9702",
                           blocked: false,
                           startDate: f.date(from: "11.05.2017")!,
                           expirationDate: f.date(from: "11.05.2019")!,
                           availableBalance: 7_500.15,
                           blockedMoney: 1_230,
                           updatingDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                           tariff: "Классика")
        return [c1,c2,c3,c4,c5,c6]
//        return []
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
}
