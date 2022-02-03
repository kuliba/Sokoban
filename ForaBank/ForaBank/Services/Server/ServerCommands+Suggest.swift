//
//  ServerCommands+Suggest.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum SuggestController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/suggestBank
         */
        struct SuggestBank: ServerCommand {
            
            let token: String
            let endpoint = "/rest/suggestBank"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: SuggestPayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [SuggestionsBank]?
                
                struct SuggestionsBank: Decodable, Equatable {
                    
                    let data: BankDataItem?
                    let unrestrictedValue: String?
                    let value: String?
                }
            }
            
            internal init(token: String, payload: SuggestPayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/suggestCompany
         */
        struct SuggestCompany: ServerCommand {
            
            let token: String
            let endpoint = "/rest/suggestCompany"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: SuggestPayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [SuggestionsCompany]?
                
                struct SuggestionsCompany: Decodable, Equatable {
                    
                    let data: CompanyData?
                    let unrestrictedValue: String?
                    let value: String?
                }
            }
            
            internal init(token: String, payload: SuggestPayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        struct SuggestPayload: Encodable {
            
            let branchType: String?
            let kpp: String?
            let query: String
            let type: String?
            
            private enum CodingKeys : String, CodingKey {
                
                case branchType = "branch_type"
                case kpp
                case query
                case type
            }
        }
    }
}
