/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

//
//struct Operations: Codable{
//    let name: String
//    let logo: String
//    let details: Details
//}
//
//struct Details: Codable {
//    let code: String
//    let nameList: nameList
//    let description: String
//    let order: String
//    let mcc: String
//    let mask: String
//    let isRequired: Bool
//    let isNotInTemplate: Bool
//    let rawLength: Int
//    
//    
//}
//struct nameList: Codable    {
//    let locale: String
//    let value: String
//}

class OperatorsListService {
    
    private let baseURLString: String
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSortedFullStatement(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Operations]?, String?) -> Void) {
        let url = baseURLString + "rrest/getOperatorsList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { [unowned self] response in
                
                //                print("csrf result: \(response.result)")  // response serialization result
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil, errorMessage)
                    return
                }
                
                switch response.result {
                case .success:
                    //                    print("JSON: \(response.result.value)") // serialized json response
                    //                    if let json = response.result.value as? BriginvestResponse<[TransactionStatement]>
                    //                        print("rest/getFullStatement result: \(json)")
                    //                        completionHandler(true, nil, nil)
                    //                    } else {
                    //                        print("rest/getFullStatement cant parse json \(String(describing: response.result.value))")
                    //                        completionHandler(false, nil, "")
                    //                    }
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    //                    print("rest/getFullStatement data: \(response.data)")
                    do {
                        if (try decoder.decode(Array<Operations>.self, from: response.data ?? Data())) is Operations {
                            print(response)
//                            let sortedTransations = DatedTransactionsStatement.sortByDays(transactions: result.data)
//                            completionHandler(true, sortedTransations, nil)
                            return
                        }
                    } catch let error as NSError {
                        print("rest/getFullStatement cant parse json \(error)")
                    }
                    completionHandler(false, nil, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil, "get profile result validation failure")
                }
        }
    }
    
    
}
