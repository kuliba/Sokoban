/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire
import UIKit



class HistoryService: HistoryServiceProtocol {


    private let host: Host
    private var datedTransactions = [DatedTransactions]()

    init(host: Host) {
        self.host = host
    }


    func getHistoryCard(headers: HTTPHeaders, completionHandler: @escaping (Bool, [HistoryCard]?) -> Void) {
        var historycard = [HistoryCard]()
        let url = host.apiBaseURL + "/rest/getCardStatement"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, historycard)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,

                        let data = json["data"] as? Array<Any> {

                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {
                                let amount = original["amount"] as? Int
                                let accountID = original["accountID"] as? Int
                                let comment = original["comment"] as? String
                                let operationType = original["operationType"] as? String




                                let historycards = HistoryCard(amount: amount!, comment: comment, operationType: operationType, accountID: accountID)

                                historycard.append(historycards)
                            }
                        }
                        completionHandler(true, historycard)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, historycard)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, historycard)
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
}
