/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class StatementService: StatementServiceProtocol {

    private let host: Host

    init(host: Host) {
        self.host = host
    }

    func getSortedFullStatement(headers: HTTPHeaders, completionHandler: @escaping (Bool, [DatedTransactionsStatement]?, String?) -> Void) {
        let url = host.apiBaseURL + "rest/getFullStatement"
       
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { [unowned self] response in
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil, errorMessage)
                    return
                }

                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    do {
                        if let result = (try decoder.decode(BriginvestResponse<[TransactionStatement]>.self, from: response.data ?? Data())) as? BriginvestResponse<[TransactionStatement]> {
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
