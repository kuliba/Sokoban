//
//  ServerCommands+User.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum UserController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/UserController/blockAccountUsingPOST
         */
        struct BlockAccount: ServerCommand {
            
            let token: String
            let endpoint = "/rest/blockAccount"
            let method: ServerCommandMethod = .post
            
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/UserController/getUserSettingsUsingGET
         */
        struct GetUserSettings: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getUserSettings"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: SettingsData?
                
                struct SettingsData: Codable, Equatable {
                    
                    let userSettingList: [UserSettingData]
                }
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/UserController/setUserSettingUsingPOST
         */
        struct SetUserSetting: ServerCommand {
            
            let token: String
            let endpoint = "/rest/setUserSetting"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let settingName: String?
                let settingSysName: String
                let settingValue: String?
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
            
            init<UserSetting: UserSettingProtocol>(token: String, userSetting: UserSetting) {
                
                self.token = token
                let userSettingData = userSetting.userSettingData
                self.payload = .init(settingName: userSettingData.name, settingSysName: userSettingData.sysName, settingValue: userSettingData.value)
            }
        }
    }
}
