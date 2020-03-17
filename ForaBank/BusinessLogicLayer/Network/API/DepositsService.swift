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

class DepositService: DepositsServiceProtocol {


    private let host: Host
    private var datedTransactions = [DatedTransactions]()

    init(host: Host) {
        self.host = host
    }

    func getBonds(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Deposit]?) -> Void) {
        var deposits = [Deposit]()
        let url = host.apiBaseURL + "rest/getDepositList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, deposits)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {

                                let depositProductName = original["depositProductName"] as? String
                                let depositProductID = original["depositProductID"] as? Int
                                if depositProductID == 10000000088 { continue }

                                var accountList: Array<Any> = original["accountList"] as! Array
                                let accountData = accountList[0] as? Dictionary<String , Any>
                                let balance = accountData!["balance"] as? Double
                                let accountNumber = accountData!["accountNumber"] as? String
                                let currencyCode = accountData!["currencyCode"] as? String
                                let ownerAgentBrief = original["ownerAgentBrief"] as? String
                                let number = original["number"] as? String
                                let dateStart =  dayMonthYear(milisecond: (original["dateStart"] as? Double)!)
                                let dateEnd =  dayMonthYear(milisecond: (original["dateEnd"] as? Double)!)
                                let minimumBalance = original["minimumBalance"] as? Double
                                let creditMinimumAmount = original["creditMinimumAmount"] as? Double
                                let isCreditOperationsAvailable  = accountData!["isCreditOperationsAvailable "] as? Bool
                                let isDebitOperationsAvailable  = accountData!["isDebitOperationsAvailable "] as? Bool
                                let initialAmount  = original["initialAmount "] as? Double
                                let interestRate = accountData!["interestRate"] as? Double
                                let customName = cardData["customName"] as? String
                                let depositId = original["depositID"] as? Int
                                let deposit = Deposit(depositProductName: depositProductName,isCreditOperationsAvailable:isCreditOperationsAvailable,
                                                      currencyCode: currencyCode, balance: balance,
                                                      accountNumber: accountNumber, customName: customName, id: depositId,
                                                      minimumBalance:minimumBalance, interestRate: interestRate, isDebitOperationsAvailable:isDebitOperationsAvailable,creditMinimumAmount:creditMinimumAmount, initialAmount:initialAmount, dateEnd: dateEnd, dateStart:dateStart)
                                deposits.append(deposit)

                            }
                        }
                        completionHandler(true, deposits)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, deposits)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, deposits)
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
