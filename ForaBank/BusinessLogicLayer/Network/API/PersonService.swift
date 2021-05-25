//
//  PersonService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 23.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire


class PersonService: PersonServiceProtocol {
    
    
   
    private let host: Host
    init(host: Host) {
      self.host = host
    }
    var person: FPerson?
    let urlString = Host.shared.apiBaseURL + "rest/getPerson"

    func personService(header: HTTPHeaders, completionHandler: @escaping (Bool?, FPerson, String?) -> Void) {
        guard let url = Foundation.URL(string: urlString) else { return }
//        let urlRequest = URLRequest(url: url)
//     let parametrs: [String: Any] = ["\(self.bodyVariable)": "\(numberCard!)" as String, "puref": "\(purefID)" as String]

        Alamofire.request(urlString , method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: header)
        .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { response in
             
             switch response.result{
             case .success:
                 do{
                     let json = response.data
                     let decoder = JSONDecoder()
                    let jsonData = try? decoder.decode(FPerson.self, from: json ?? Data.init())
                    
                    
                     self.person = jsonData
//                     self.AnywayPayment(headers: header) { (success, anywayPayment, errorMessage) in
//
//                     }
                    completionHandler(true, self.person!, response.error?.localizedDescription)
                 } catch {
                     print(error)
                 }
             case . failure( _):
                 print("failture")
             }
        }

    }
    
    
}
