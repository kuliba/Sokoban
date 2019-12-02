//
//  ServiceBest2Pay.swift
//  ForaBank
//
//  Created by Дмитрий on 26/11/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

class ServiceBest2Pay: UIViewController {

    let url = "https://test.best2pay.net/webapi/P2PTransfer"
    
    private var sector: Int? = 1009
    private var amount: Int? = 100
    private var fee: Int? = 7000
    private var currency: Int? = 643
    private var pan1: String? = "4656260150230695"
    private var cvc: String? = "314"
    private var month: Int? = 07
    private var year: Int? = 2024
    private var pan2: String? = "4809388889655340"
    
    
     func best2Pay(headers: HTTPHeaders,
                        completionHandler: @escaping (Bool, String?, String?, String?) -> Void) {
        let url = "https://test.best2pay.net/webapi/P2PTransfer"
        print(url)
        let parameters: [String: AnyObject] = [
            "sector": sector as AnyObject,
            "amount": amount as AnyObject,
            "fee": fee as AnyObject,
            "currency": currency as AnyObject,
            "pan1": pan1 as AnyObject,
            "pan1": cvc as AnyObject,
            "pan1": month as AnyObject,
            "pan1": year as AnyObject,
            "pan1": pan2 as AnyObject,
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage, nil, nil)

                    return
                }

                switch response.result {
                case .success:
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil, self.pan1, self.pan2)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil, nil, nil)
                }
        }
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
