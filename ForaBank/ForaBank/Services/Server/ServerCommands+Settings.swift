//
//  ServerCommands+Settings.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.10.2022.
//

import Foundation

extension ServerCommands {
    
    enum SettingsController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getAppSettings
         */
        
        struct GetAppSettings: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getAppSettings"
            let method: ServerCommandMethod = .get
            let payload: Payload?

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AppSettingsData?
                
                struct AppSettingsData: Decodable, Equatable {
                    
                    let appSettings: AppSettings
                }
            }
            
            init(token: String) {
                
                self.token = token
                self.payload = nil
            }
        }
    }
}
