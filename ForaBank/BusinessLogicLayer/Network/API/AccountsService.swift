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



class AccountsService: AccountsServiceProtocol {

    private let host: Host
    private var datedTransactions = [DatedTransactions]()

    init(host: Host) {
        self.host = host
    }


    func getDepos(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Account]?) -> Void) {
        var accounts = [Account]()
        let url = host.apiBaseURL + "rest/getDepositList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, accounts)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,

                        let data = json["data"] as? Array<Any> {

                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                var original = cardData["original"] as? Dictionary<String, Any> {

                                var accountList: Array<Any> = original["accountList"] as! Array
                                let accountData = accountList[0] as? Dictionary<String , Any>
                                guard let accountNumber = accountData?["accountNumber"] as? String,
                                    let currencyCode = accountData?["currencyCode"] as? String,

                                    
                                    let balance = accountData?["balance"] as? Double else {
                                        continue
                                }

                                original["accountNumber"] = accountNumber
                                original["currencyCode"] = currencyCode
                                original["balance"] = balance
                                let dateStart = dayMonthYear(milisecond: Double((original["dateStart"] as? Double)!))
                                let isClosed = original["isClosed"] as? Bool

                                let depositProductName = original["depositProductName"] as? String
                                let depositProductID = original["depositProductID"] as? Int
                                let account = Account.from(NSDictionary(dictionary: original))

                                guard let nonNilAccount = account, account?.productId == 10000000088 else { continue }

                                accounts.append(nonNilAccount)
                            }
                        }
                        completionHandler(true, accounts)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, accounts)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, accounts)
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
