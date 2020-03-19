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
    
    //получаем курсы валюты
    func getExchangeCurrencyRates(headers: HTTPHeaders, currency: String, completionHandler: @escaping (Bool, Currency?) -> Void) {
        let url = host.apiBaseURL + "rest/getExchangeCurrencyRates"
        let parameters: [String: AnyObject] = [
            "currencyCodeAlpha": currency as AnyObject,
        ]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                
                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                    let data = json["data"] as? Dictionary<String, Any>{
                        let buyCurrency = data["rateBuy"] as? Double
                        let saleCurrency = data["rateSell"] as? Double
                        //let rateCBCurrency = data[""]
                        let currencyData = Currency(buyCurrency: buyCurrency,
                                                    saleCurrency: saleCurrency,
                                                    rateCBCurrency: nil)
                        completionHandler(true, currencyData)
                        return
                    }else{
                        completionHandler(false, nil)
                        return
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                }
        }
        
        
    }
    
    //получаем курс валюты ЦБ
    func getABSCurrencyRates(headers: HTTPHeaders, currencyOne: String, currencyTwo: String, rateTypeID: Int, completionHandler: @escaping (Bool, Double?) -> Void) {
        //var currencys = [Currency]()
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
                            
                            guard let json = response.result.value as? Dictionary<String, Any> else {
                                completionHandler(false, nil)
                                return
                            }
                            guard let data = json["data"] as? Array<Dictionary<String, Any>> else {
                                completionHandler(false, nil)
                                return
                            }
                            
                            guard let rateCB = data[0]["rate"] as? Double else {
                                completionHandler(false, nil)
                                return
                            }
                            
                            completionHandler(true, rateCB)
                            return
                            
                        case .failure(let error):
                            print("\(error) \(self)")
                        }
                }
    }
}


