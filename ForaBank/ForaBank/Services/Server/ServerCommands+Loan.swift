//
//  ServerCommands+Loan.swift
//  ForaBank
//
//  Created by Дмитрий on 25.03.2022.
//

import Foundation

extension ServerCommands {
    
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
        
        
        //TODO: tests
        /*
         http://192.168.50.113:8080/swagger-ui/index.html#/LoanController/saveLoanCustomName
         */
        struct SaveLoanName: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/saveLoanName"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        struct BasePayload: Encodable {

            let endDate: String?
            let id: Int
            let name: String?
            let startDate: String?
            let statementFormat: StatementFormat?
        }
    }
}
