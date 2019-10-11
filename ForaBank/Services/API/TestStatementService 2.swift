/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

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
