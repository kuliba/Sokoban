//
//  BlockAccountService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire
class BlockUserService : BlockUserProtocolService{
    
    private let host: Host

    
    init(host: Host) {
        self.host = host
    }
//    let url = host.apiBaseURL + "rest/getCardInfo"

       func blockUser(headers: HTTPHeaders, completionHandler: @escaping (Bool, String?) -> Void) {
        var urlString = host.apiBaseURL + "rest/blockAccount"
            guard let url = Foundation.URL(string: urlString) else { return }
    //        let urlRequest = URLRequest(url: url)
             Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                             .validate(statusCode: MultiRange(200..<300, 401..<402))
                             .validate(contentType: ["application/json"])
                             .responseJSON { [unowned self] response in
                                 guard let json = response.result.value as? Dictionary<String, Any>,
                                     let result = json["result"] as? String, result == "OK" else {
                                         print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
                                        completionHandler(false, "error")
                                         return
                                 }

                                 switch response.result {
                                 case .success:
                                     completionHandler(false, "error")
                                 case .failure(let error):
                                     print("\(error) \(self)")
                                     completionHandler(false, "error")
                                 }
                         }
        }
}
