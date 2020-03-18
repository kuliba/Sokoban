//
//  Currencys.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 18.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class CurrencysService: CurrencysProtocol {
    
    private let host: Host

    init(host: Host) {
        self.host = host
    }
    
    func getABSCurrencyRates(headers: HTTPHeaders, currencyOne: String, currencyTwo: String, rateTypeID: Int, completionHandler: @escaping (Bool, [Currency]?) -> Void) {
        var currencys = [Currency]()
        let url = host.apiBaseURL + "rest/getABSCurrencyRates"
        let date = getDateCurrencys(data: Date())
        let parameters: [String: AnyObject] = [
            "currencyCode": currencyOne as AnyObject,
            "currencyCode2": currencyTwo as AnyObject,
            "date": date as AnyObject,
            "rateTypeID": rateTypeID as AnyObject
        ]
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: MultiRange(200..<300, 401..<402))
                    .validate(contentType: ["application/json"])
                    .responseJSON { [unowned self] response in
                        
                        switch response.result {
                        case .success:
                            print("getABSCurrencyRates \(String(describing: response.result.value))")
                            
                        case .failure(let error):
                            print("\(error) \(self)")
                        }
                }
    }
    
    
}
