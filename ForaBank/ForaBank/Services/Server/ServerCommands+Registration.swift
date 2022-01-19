//
//  ServerComands+Registration.swift
//  ForaBank
//
//  Created by Дмитрий on 18.01.2022.
//

import Foundation

extension ServerCommands{
    
    enum RegistrationContoller{
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/registration/checkClient
         */
        struct CheckClient: ServerCommand {
            
            let token: String
            let endpoint = "/registration/checkClient"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                
                let cardNumber: String
                let cryptoVersion: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/registration/doRegistration
         */
        struct DoRegistration: ServerCommand {
            
            let token: String
            let endpoint = "/registration/doRegistration"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String
                let model: String
                let operationSystem = "iOS"
                let pushDeviceId: String
                let pushFcmToken: String    
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/registration/getCode
         */
        struct GetCode: ServerCommand {
            
            let token: String
            let endpoint = "/registration/getCode"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil
            
            struct Payload: Encodable {}

            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
            }
        }
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/registration/setDeviceSettings
         */
        struct SetDeviceSettings: ServerCommand {
            
            let token: String
            let endpoint = "/registration/setDeviceSettings"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            
            struct Payload: Encodable {
                let cryptoVersion: String
                let pushDeviceId: String
                let pushFcmToken: String
                let serverDeviceGUID: String
                let settings: [Settings]
            }
            
            struct Settings: Encodable {
                let isActive: Bool
                let type: SettingsType
                let value: String
            }
            
            enum SettingsType: String, Encodable { case pin, touchid, faceid }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/registration/verifyCode
         */
        struct VerifyCode: ServerCommand {

            let token: String
            let endpoint = "/registration/verifyCode"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            
            struct Payload: Encodable {
                let cryptoVersion: String
                let verificationCode: String
            }

            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.payload = payload
                self.token = token
            }
        }
    }
}
