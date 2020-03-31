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


    func getHistoryCard(headers: HTTPHeaders, cardNumber: String, completionHandler: @escaping (Bool, [DatedCardTransactionsStatement]?) -> Void) {
        var historycard = [DatedCardTransactionsStatement]()
        let url = host.apiBaseURL + "/rest/getCardStatement"
         var parametrs: [String: Any] = ["cardNumber": cardNumber as AnyObject, "id": 0, "name": "string", "statementFormat": "CSV"]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parametrs, encoding: JSONEncoding.default, headers: headers)
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
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    do {
                        if let result = (try decoder.decode(BriginvestResponse<[TransactionCardStatement]>.self, from: response.data ?? Data())) as? BriginvestResponse<[TransactionCardStatement]> {
                            
                            let sortedTransations = DatedCardTransactionsStatement.sortByDays(transactions: result.data)
                            completionHandler(true, sortedTransations)
                            //print(sortedTransations)
                            return
                        }
                    } catch let error as NSError {
                        print("rest/getFullStatement cant parse json \(error)")
                    }
                    completionHandler(false, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
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
