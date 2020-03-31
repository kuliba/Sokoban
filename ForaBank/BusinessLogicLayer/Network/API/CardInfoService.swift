/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class CardInfoService: CardInfoServiceProtocol {

    private let host: Host
    private var datedTransactions = [DatedTransactions]()

    init(host: Host) {
        self.host = host
    }

    var cardNumber = ""
    
    func getCardInfo(cardNumber: String?, headers: HTTPHeaders, completionHandler: @escaping (Bool, [AboutItem]?) -> Void) {
        var cards = [AboutItem]()
        let url =  "https://git.briginvest.ru/dbo/api/v2/rest/getCardInfo"

        let parametrs: [String: Any] = ["cardNumber": cardNumber!]
        
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parametrs, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, cards)
                    return
                }

                
              switch response.result {
                         case .success:
                              if let json = response.result.value as? Dictionary<String, Any>,
                                                    let data = json["data"] as? Dictionary<String, Any>,
                                                     let original = data["original"] as? Dictionary<String, Any>,
                                //var startDate: String = dayMonthYear(milisecond: Double(original["dateStart"] as! Int)),
                                let dateEnd: String = dayMonthYear(milisecond: Double(original["dateEnd"] as! Int)){
                                     for cardData in data {
                                         if let cardData = cardData as? Dictionary<String, Any>,
                                         let original = cardData["original"] as? Dictionary<String, Any> {
                                             let startDate = original["dateStart"] as? Int

                                             let dateEnd = original["dateEnd"] as? Int
                                             //let customName = cardData["customName"] as? String

                                             //let title = original["name"] as? String
                                             //_ = original["account"] as? String
                                             //let number = original["number"] as? String
                                             //let maskedNumber = original["maskedNumber"] as? String
                                             //let availableBalance = original["balance"] as? Double
                                             //let branch = original["branch"] as? String
                                             //let id = original["cardID"] as? String
                                             //let product = (original["product"] as? String) ?? ""
                                             //var expirationDate: String? = dayMonthYear(milisecond: original["validThru"] as! Double)

                                            let card = AboutItem(title: String(startDate!), value: String(dateEnd!))
                                        
                                             cards.append(card)
                                         }
                                 }
                                 let card = AboutItem(title: "Дата окончания действия карты", value: String(dateEnd))
                                 cards.append(card)
                                 completionHandler(true, cards)
                             } else {
                                 print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                                 completionHandler(false, cards)
                             }

                         case .failure(let error):
                             print("rest/getCardList \(error) \(self)")
                             completionHandler(false, cards)
                         }
                 
                }

        }
    }

 





