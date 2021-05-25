//
//  GetVerificationCode.swift
//  ForaBank
//
//  Created by Дмитрий on 19.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire


class GetVerificationService: getVerificationCodeProtocol{
 
    
        private let host: Host
        init(host: Host) {
          self.host = host
        }

        let urlString = Host.shared.apiBaseURL + "rest/getVerificationCode"

    func getVerificationCode(headers: HTTPHeaders, completionHandler: @escaping (Bool, String) -> Void) {
            guard let url = Foundation.URL(string: urlString) else { return }
    //        let urlRequest = URLRequest(url: url)
    //     let parametrs: [String: Any] = ["\(self.bodyVariable)": "\(numberCard!)" as String, "puref": "\(purefID)" as String]

            Alamofire.request(urlString , method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
                .responseJSON { response in
                 
                 switch response.result{
                 case .success:
                     do{
                         let json = response.data
                         let decoder = JSONDecoder()
                        let jsonData = try? decoder.decode(FPerson.self, from: json ?? Data.init())
                        
                        
                         
    //                     self.AnywayPayment(headers: header) { (success, anywayPayment, errorMessage) in
    //
    //                     }
                        completionHandler(true, "nil")
                     } catch {
                         print(error)
                     }
                 case . failure( _):
                     print("failture")
                 }
            }

        }
}
