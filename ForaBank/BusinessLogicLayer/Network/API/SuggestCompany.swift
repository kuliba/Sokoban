/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class SuggestCompanyService: SuggestCompanyServiceProtocol {
 

    private let host: Host
    private var datedTransactions = [DatedTransactions]()

    init(host: Host) {
        self.host = host
    }

   func getSuggestCompany(bicBank: String?, headers: HTTPHeaders, completionHandler: @escaping (Bool, [BankSuggest]?, String?) -> Void) {
    
    var cards = [BankSuggest]()
    let url = Host.shared.apiBaseURL + "rest/suggestCompany"
    let parametrs: [String: Any] = ["query": bicBank as AnyObject,]
        
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parametrs, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, cards, bicBank)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any>{
                            for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                            let _ = cardData["data"] as? Dictionary<String, Any> {
                                let value = cardData["value"] as? String
                                let dataCompany =  cardData["data"] as? Dictionary<String, Any>
                                let kpp = dataCompany!["kpp"] as? String
                                let card = BankSuggest(value: value, kpp: kpp ?? "")
                               
                                cards.append(card)
                            }
                        }
                        completionHandler(true, cards, bicBank)
                    } else {
                        print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, cards, bicBank)
                    }

                case .failure(let error):
                    print("rest/getCardList \(error) \(self)")
                    completionHandler(false, cards, bicBank)
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
