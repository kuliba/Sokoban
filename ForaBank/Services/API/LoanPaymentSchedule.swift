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



class LoanPaymentSchedule: LoanPaymentScheduleProtocol {
    

    var loan = "10001475158"

    private let baseURLString: String
    private var datedTransactions = [DatedTransactions]()

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }


      func getLoansPayment(headers: HTTPHeaders, completionHandler: @escaping (Bool, [LaonSchedules]?) -> Void) {
        var loanPaymentSchedule = [LaonSchedules]()
        let url = baseURLString + "rest/getLoanPaymentSchedule"
        let parameters: [String: AnyObject] = [
               "id": loan as AnyObject
           ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, loanPaymentSchedule)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,

                        let data = json["data"] as? Array<Any> {

                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                var original = cardData["actionEntryList"] as? Dictionary<String, Any> {

                                var actionEntryList: Array<Any> = original["actionType"] as! Array
                                let accountData = actionEntryList[0] as? Dictionary<String , Any>

                                guard let accountNumber = actionEntryList as? Dictionary<String , Any>,
                                    let actionType = accountNumber["actionType"] as? String,
                                    let balance = accountData?["balance"] as? Double else {
                                        continue
                                }

                                original["actionType"] = actionType
                                original["actionEntryList"] = actionEntryList
                                original["balance"] = balance

                                let depositProductName = original["depositProductName"] as? String
                                let depositProductID = original["depositProductID"] as? Int
                                let loanPayment = LaonSchedules.from(NSDictionary(dictionary: original))
                            }
                        }
                        completionHandler(true, loanPaymentSchedule)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, loanPaymentSchedule)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, loanPaymentSchedule)
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
