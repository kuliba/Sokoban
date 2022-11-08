//
//  ServerCommands+Person.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum PersonController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getClientInfo
         */
        struct GetClientInfo: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getClientInfo"
            let method: ServerCommandMethod = .post
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ClientInfoData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getPersonImage
         */
        
        struct GetPersonImage: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPersonImage"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/updatePersonImage
         */
        struct UpdatePersonImage: ServerUploadCommand {
            
            let token: String
            let endpoint = "/rest/updatePersonImage"
            let method: ServerCommandMethod = .post
            let media: ServerCommandMediaParameter
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, media: ServerCommandMediaParameter) {
                
                self.token = token
                self.media = media
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/removePersonImage
         */
        struct RemovePersonImage: ServerCommand {
            
            let token: String
            let endpoint = "/rest/removePersonImage"
            let method: ServerCommandMethod = .delete
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getPerson
         */
        struct GetPerson: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getPerson"
            let method: ServerCommandMethod = .post
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: PersonData?
                
                struct PersonData: Codable, Equatable {
                    
                    let personId: Int
                    let lastName: String
                    let firstname: String
                    let patronymic: String?
                }
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/setPersonCustomName
         */
        struct SetPersonCustomName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/setPersonCustomName"
            let method: ServerCommandMethod = .patch
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let customName: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/removePersonImage
         */
        struct RemovePersonCustomName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/removePersonCustomName"
            let method: ServerCommandMethod = .delete
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/deleteAllPersonProperties
         */
        struct DeleteAllPersonProperties: ServerCommand {
            
            let token: String
            let endpoint = "/rest/deleteAllPersonProperties"
            let method: ServerCommandMethod = .delete
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getPersonAgreement
         */
        
        struct GetPersonAgreement: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getPersonAgreements"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PersonAgreement]?
            }
            
            internal init(token: String, system: PersonAgreement.System, type: PersonAgreement.TypeDocument?) {
                
                self.token = token
                if let type = type {
                    
                    self.parameters = [.init(name: "system", value: system.rawValue), .init(name: "type", value: type.rawValue)]
                    
                } else {
                    
                    self.parameters = [.init(name: "system", value: system.rawValue)]
                }
            }
        }
    }
}
