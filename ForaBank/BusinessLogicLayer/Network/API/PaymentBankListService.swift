//
//  PaymentBankListService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 23.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//
import Alamofire
import Foundation

class PaymentBankListService: paymentBankListProtocol {
    
    func getBankList(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool,_ bankList: [BLBankList], String?) -> Void){

        let url = Host.shared.apiBaseURL + "rest/fastPaymentBankList"
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: MultiRange(200..<300, 401..<402))
                .validate(contentType: ["application/json"])
                .responseJSON { [unowned self] response in
                    
                    let jsonData = response.data
                    let decoder = JSONDecoder()
                    let data = try? decoder.decode([BLBankList].self, from: jsonData!)
                    print(data)
        }
    }

}
