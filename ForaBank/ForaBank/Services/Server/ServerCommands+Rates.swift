//
//  ServerCommands+Rates.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum RatesController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/RatesController/getExchangeCurrencyRatesUsingPOST
         */
        struct GetExchangeCurrencyRates: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getExchangeCurrencyRates"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let currencyCodeAlpha: String
                var branchID: Int? = nil
                var cashID: Int? = nil
                var currencyCodeNumeric: String? = nil
                var currencyID: Int? = nil
                var dateTime: Date? = nil
                var rateTypeID: Int? = nil
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ExchangeRateData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, currency: Currency) {
                
                self.token = token
                self.payload = .init(currencyCodeAlpha: currency.description)
            }
        }
    }
}
