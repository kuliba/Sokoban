//
//  ServerCommands+Loan.swift
//  ForaBank
//
//  Created by Дмитрий on 25.03.2022.
//

import Foundation

extension ServerCommands {
    
    //TODO: write tests ASAP
    
    enum LoanController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getPersonsCredit
         */
        struct GetPersonsCredit: ServerCommand {

            let token: String?
            let endpoint = "/rest/getPersonsCredit"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let id: Int
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: PersonsCreditItem?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
