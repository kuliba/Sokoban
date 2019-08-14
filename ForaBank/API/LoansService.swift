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
        private var loans = [Loan]()
        private var datedTransactions = [DatedTransactions]()
        
        init(baseURLString: String) {
            self.baseURLString = baseURLString
        }
        
        
        func getLoans(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Loan    ]?) -> Void) {
            loans = [Loan]()
            let url = baseURLString + "rest/getLoanList"
            Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: MultiRange(200..<300, 401..<402))
                .validate(contentType: ["application/json"])
                .responseJSON { [unowned self] response in
                    
                    if let json = response.result.value as? Dictionary<String, Any> ,
                        let errorMessage = json["errorMessage"] as? String {
                        print("\(errorMessage) \(self)")
                        completionHandler(false, self.loans)
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
                                    let loan = Loan(
                                        currencyCode:currencyCode
                                                        )
                                    self.loans.append(loan)
                                }
                            }
                            completionHandler(true, self.loans)
                        } else {
                            print("rest/getLoanList cant parse json \(String(describing: response.result.value))")
                            completionHandler(false, self.loans)
                        }
                        
                    case .failure(let error):
                        print("rest/getLoanList \(error) \(self)")
                        completionHandler(false, self.loans)
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
