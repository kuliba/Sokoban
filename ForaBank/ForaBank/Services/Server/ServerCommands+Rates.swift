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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/RatesController/getExchangeCurrencyRatesUsingPOST
         */
        struct GetExchangeCurrencyRates: ServerCommand {

            let token: String
            let endpoint = "/rest/getExchangeCurrencyRates"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let branchID: Int?
                let cashID: Int?
                let currencyCodeAlpha: String
                let currencyCodeNumeric: String?
                let currencyID: Int?
                let dateTime: Date?
                let rateTypeID: Int
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: RatesExchangeData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
    }
}
