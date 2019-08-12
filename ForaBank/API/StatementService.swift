//
//  StatementService.swift
//  ForaBank
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class StatementService: StatementServiceProtocol {
    
    private let baseURLString: String
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func getSortedFullStatement(headers: HTTPHeaders, completionHandler: @escaping (Bool, [DatedTransactionsStatement]?, String?) -> Void) {
        let url = baseURLString + "rest/getFullStatement"
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
                        if let result = (try decoder.decode(BriginvestResponse<[TransactionStatement]>.self, from: response.data ?? Data())) as? BriginvestResponse<[TransactionStatement]> {
//                            print(response)
                            let sortedTransations = DatedTransactionsStatement.sortByDays(transactions: result.data)
                            completionHandler(true, sortedTransations, nil)
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
