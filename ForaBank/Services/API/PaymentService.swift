/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class PaymentServices: PaymetsServiceProtocol {
    
    private let baseURLString: String
    private var datedTransactions = [DatedTransactions]()
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func getPaymentsList(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Operations]?) -> Void) {
        var payments = [Operations]()
        let url = baseURLString + "rest/getOperatorsList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, payments)
                    return
                }
                
                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>{
                                let name = cardData["name"] as? String
                       
                                
                                let payment = Operations(name: name)
                               payments.append(payment)
                            }
                            print(payments)
                        }
                        completionHandler(true, payments)
                    } else {
                        print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, payments)
                    }
                    
                case .failure(let error):
                    print("rest/getCardList \(error) \(self)")
                    completionHandler(false, payments)
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
