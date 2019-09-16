/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class CardService: CardServiceProtocol {

    private let baseURLString: String
    private var cards = [Card]()
    private var datedTransactions = [DatedTransactions]()

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }

    func getCardList(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Card]?) -> Void) {
        cards = [Card]()
        /*
        var expirationDate: Date? = nil
        let validThru = 1577739600000/1000
        expirationDate = Date(timeIntervalSince1970: TimeInterval((validThru)))
        print(expirationDate)
        var card = Card(type: CardType.visaDebet,
                        paypass: nil,
                        title: "ТП ЗП.ПРЕМИУМ Visa Classic RUB",
                        customName: "ТП ЗП.ПРЕМИУМ Visa Classic RUB",
                        number: "4256901050031063",
                        blocked: nil,
                        startDate: nil,
                        expirationDate: expirationDate,
                        availableBalance: 1234.56,
                        blockedMoney: nil,
                        updatingDate: nil,
                        tariff: nil,
                        id: "10000061908",
                        branch: "АКБ \"ФОРА-БАНК\" (АО)",
                        maskedNumber: "4256-XXXX-XXXX-1063")
        self.cards.append(card)
        completionHandler(true, cards)*/
        /*
        let string = """
{
  "result": "OK",
  "errorMessage": null,
  "data": [
    {
      "original": {
        "number": "4256901050031063",
        "numberMasked": "4256-XXXX-XXXX-1063",
        "balance": 1234.56,
        "currency": "RUB",
        "productType": "CARD",
        "cardID": 10000061908,
        "name": "ТП ЗП.ПРЕМИУМ Visa Classic RUB",
        "validThru": 1577739600000,
        "status": "Действует",
        "holderName": "ALEXANDER KRYUKOV",
        "product": "VISA CLASSIC R-3",
        "branch": "АКБ "ФОРА-БАНК" (АО)",
        "miniStatement": []
      },
      "customName": "ТП ЗП.ПРЕМИУМ Visa Classic RUB"
    }
  ]
}
"""
        print( string[string.index(string.startIndex, offsetBy: 529) ..< string.endIndex] )
        let data = string.data(using: .utf8)!
        var jsonObject: Dictionary<String, Any>? = nil
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String,Any>
            {
                jsonObject = jsonArray
                print("jsonArray \(jsonArray)") // use the json here
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        if let json = jsonObject,
            let data = json["data"] as? Array<Any> {
            for cardData in data {
                if let cardData = cardData as? Dictionary<String, Any>,
                    let original = cardData["original"] as? Dictionary<String, Any> {
                    let customName = cardData["customName"] as? String
                    
                    var type: CardType? = nil
                    if let product = original["product"] as? String {
                        if product.range(of: "mastercard", options: .caseInsensitive) != nil {
                            type = CardType.mastercard
                        } else if product.range(of: "visa", options: .caseInsensitive) != nil {
                            type = CardType.visaDebet
                        }
                    }
                    let title = original["name"] as? String
                    let number = original["number"] as? String
                    let maskedNumber = original["maskedNumber"] as? String
                    var blocked: Bool? = nil
                    if let status = original["status"] as? String {
                        if status.range(of: "Действует", options: .caseInsensitive) != nil {
                            blocked = false
                        } else {
                            blocked = true
                        }
                    }
                    let availableBalance = original["balance"] as? Double
                    let branch = original["branch"] as? String
                    let id = original["cardID"] as? String
                    
                    var card = Card(type: type,
                                    paypass: nil,
                                    title: title,
                                    customName: customName,
                                    number: number,
                                    blocked: blocked,
                                    startDate: nil,
                                    expirationDate: nil,
                                    availableBalance: availableBalance,
                                    blockedMoney: nil,
                                    updatingDate: nil,
                                    tariff: nil,
                                    id: id,
                                    branch: branch,
                                    maskedNumber: maskedNumber)
                    self.cards.append(card)
                }
            }
            completionHandler(true, self.cards)
        } else {
            print("rest/getCardList cant parse json \(data)")
            completionHandler(false, self.cards)
        }*/

        let url = baseURLString + "rest/getCardList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, self.cards)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {
                                let customName = cardData["customName"] as? String

                                var type: CardType? = nil
                                if let product = original["product"] as? String {
                                    if product.range(of: "mastercard", options: .caseInsensitive) != nil {
                                        type = CardType.mastercard
                                    } else if product.range(of: "visa", options: .caseInsensitive) != nil {
                                        type = CardType.visaDebet
                                    }
                                }
                                let title = original["name"] as? String
                                _ = original["account"] as? String
                                let number = original["number"] as? String
                                let maskedNumber = original["maskedNumber"] as? String
                                var blocked: Bool? = nil
                                if let status = original["status"] as? String {
                                    if status.range(of: "Действует", options: .caseInsensitive) != nil {
                                        blocked = false
                                    } else {
                                        blocked = true
                                    }
                                }
                                let availableBalance = original["balance"] as? Double
                                let branch = original["branch"] as? String
                                let id = original["cardID"] as? String
                                let product = (original["product"] as? String) ?? ""
                                var expirationDate: String? = dayMonthYear(milisecond: original["validThru"] as! Double)

                                let card = Card(type: type,
                                                paypass: nil,
                                                title: title,
                                                customName: customName, number: number,
                                                blocked: blocked,
                                                startDate: nil,
                                                expirationDate: expirationDate,
                                                availableBalance: availableBalance,
                                                blockedMoney: nil,
                                                updatingDate: nil,
                                                tariff: nil,
                                                id: id,
                                                branch: branch,
                                                maskedNumber: maskedNumber,
                                                product: product)
                                self.cards.append(card)
                            }
                        }
                        completionHandler(true, self.cards)
                    } else {
                        print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, self.cards)
                    }

                case .failure(let error):
                    print("rest/getCardList \(error) \(self)")
                    completionHandler(false, self.cards)
                }
        }
    }

    func blockCard(withNumber num: String, completionHandler: @escaping (Bool) -> Void) {
//        for i in 0..<cards.count {
//            if cards[i].number == num {
//                cards[i].blocked = true
//            }
//        }
        completionHandler(false)
    }

    func getTransactionsStatement(forCardNumber: String, fromDate: Date, toDate: Date, headers: HTTPHeaders, completionHandler: @escaping (Bool, [DatedTransactions]?) -> Void) {
        completionHandler(false, datedTransactions)
    }



}
