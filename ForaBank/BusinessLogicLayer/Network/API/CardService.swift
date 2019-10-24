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
    private var datedTransactions = [DatedTransactions]()

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }

    func getCardList(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Card]?) -> Void) {
        var cards = [Card]()
        let url = baseURLString + "rest/getCardList"

        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, cards)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {
                                //                                let customName = cardData["customName"] as? String
                                //                                let title = original["name"] as? String
                                //                                _ = original["account"] as? String
                                //                                let number = original["number"] as? String
                                //                                let maskedNumber = original["maskedNumber"] as? String
//                                let availableBalance = original["balance"] as? Double
//                                let branch = original["branch"] as? String
//                                let id = original["cardID"] as? String
//                                let product = (original["product"] as? String) ?? ""
//                                var expirationDate: String? = dayMonthYear(milisecond: original["validThru"] as! Double)

                                guard let card = Card.from(NSDictionary(dictionary: original)) else { return }
                                cards.append(card)
                            }
                        }
                        completionHandler(true, cards)
                    } else {
                        print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, cards)
                    }

                case .failure(let error):
                    print("rest/getCardList \(error) \(self)")
                    completionHandler(false, cards)
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
