//
//  TestStatementService.swift
//  ForaBank
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestStatementService: StatementServiceProtocol {
    func getSortedFullStatement(headers: HTTPHeaders, completionHandler: @escaping (Bool, [DatedTransactionsStatement]?, String?) -> Void) {
        
        if let fullStatementAsset = NSDataAsset(name: "fullStatement") {
            let fullStatementData = fullStatementAsset.data

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970

            do {
                if let response = (try decoder.decode(BriginvestResponse<[TransactionStatement]>.self, from: fullStatementData)) as? BriginvestResponse<[TransactionStatement]> {
//                    print(response)
                    let sortedTransations = DatedTransactionsStatement.sortByDays(transactions: response.data)
                    completionHandler(true, sortedTransations, nil)
                    return
                }
            } catch let error as NSError {
                print(error)
            }
            completionHandler(false, nil, nil)
        }
    }
}
