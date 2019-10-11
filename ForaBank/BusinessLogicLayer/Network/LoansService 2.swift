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



class LoansService: LoansServiceProtocol {



    private let baseURLString: String
    private var datedTransactions = [DatedTransactions]()

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }


    func getLoans(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Loan]?) -> Void) {
        var loans = [Loan]()
        let url = baseURLString + "rest/getLoanList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, loans)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {
                                let currencyCode = original["currencyCode"] as? String
                                let Amount = original["Amount"] as? Int?
                                if(Amount != nil) {
                                    print(Amount! as Any) // развернутое значение
                                } else {
                                    print("0") // nil
                                }

                                let branchBrief = original["branchBrief"] as? String
                                var dateValue: String? = dayMonthYear(milisecond: original["dateValue"] as! Double)
                                let number = original["number"] as? String
                                let principalDebt = original["principalDebt"] as? Double
                                if principalDebt == 0 { continue }
                                let userAnnual = original["userAnnual"] as? Double
                                 let loanID = original["loanID"] as? Int
                                let loan = Loan(
                                    Amount: Amount!,
                                    currencyCode: currencyCode, principalDebt: principalDebt, userAnnual: userAnnual, branchBrief: branchBrief, number: number, DateValue: dateValue, loanID: loanID!
                                )
                                loans.append(loan)
                            }
                        }
                        completionHandler(true, loans)
                    } else {
                        print("rest/getLoanList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, loans)
                    }

                case .failure(let error):
                    print("rest/getLoanList \(error) \(self)")
                    completionHandler(false, loans)
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
