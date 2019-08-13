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

    
    
    class DeposService: DeposServiceProtocol {
        
        
        
        private let baseURLString: String
        private var datadeps = [Depos]()
        private var datedTransactions = [DatedTransactions]()
        
        init(baseURLString: String) {
            self.baseURLString = baseURLString
        }
        
        
        func getDepos(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Depos    ]?) -> Void) {
            datadeps = [Depos]()
            let url = baseURLString + "rest/getDepositList"
            Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: MultiRange(200..<300, 401..<402))
                .validate(contentType: ["application/json"])
                .responseJSON { [unowned self] response in
                    
                    if let json = response.result.value as? Dictionary<String, Any> ,
                        let errorMessage = json["errorMessage"] as? String {
                        print("\(errorMessage) \(self)")
                        completionHandler(false, self.datadeps)
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
                                    var accountList:Array<Any> = original["accountList"] as! Array
                                    let accountData = accountList[0] as? Dictionary<String , Any>
                                    let balance = accountData!["balance"] as? Double
                                    let accountNumber =  accountData!["accountNumber"] as? String
                                    let currencyCode =  accountData!["currencyCode"] as? String
                                    let datadep = Depos(depositProductName:depositProductName,
                                                        currencyCode:currencyCode, balance: balance,
                                                        accountNumber: accountNumber)
                                    self.datadeps.append(datadep)
                                }
                            }
                            completionHandler(true, self.datadeps)
                        } else {
                            print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                            completionHandler(false, self.datadeps)
                        }
                        
                    case .failure(let error):
                        print("rest/getDepositList \(error) \(self)")
                        completionHandler(false, self.datadeps)
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
