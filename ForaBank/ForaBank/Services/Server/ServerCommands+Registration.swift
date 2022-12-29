//
//  ServerComands+Registration.swift
//  ForaBank
//
//  Created by Дмитрий on 18.01.2022.
//

import Foundation

extension ServerCommands {
    
    enum RegistrationContoller {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/registration/checkClient
         */
        struct CheckClient: ServerCommand {
            
            let token: String
            let endpoint = "/registration/checkClient"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cardNumber: String
                let cryptoVersion: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
                
                struct Data: Codable, Hashable {
                    
                    let phone: String
                }
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/registration/doRegistration
         */
        struct DoRegistration: ServerCommand {
            
            let token: String
            let endpoint = "/registration/doRegistration"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String?
                let pushDeviceId: String
                let pushFcmToken: String
                let model: String
                let operationSystem: String
                let operationSystemVersion: String?
                let appVersion: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: String?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/registration/getCode
         */
        struct GetCode: ServerCommand {
            
            let token: String
            let endpoint = "/registration/getCode"
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/registration/setDeviceSettings
         */
        struct SetDeviceSettings: ServerCommand {
            
            let token: String
            let endpoint = "/registration/setDeviceSettings"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String?
                let pushDeviceId: String
                let pushFcmToken: String
                let serverDeviceGUID: String
                let settings: [Settings]
            }
            
            struct Settings: Encodable {
                
                let type: String
                let value: String?
                let isActive: Bool
            }
            
            enum SettingsType: String, Encodable { case pin, touchId, faceId }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(credentials: SessionCredentials, pushDeviceId: String, pushFcmToken: String, serverDeviceGUID: String, loginValue: String, availableSensorType: BiometricSensorType?, isSensorEnabled: Bool) throws {
                
                let cryptoVersion = "1.0"
                let pushDeviceIdEncrypted = try credentials.csrfAgent.encrypt(pushDeviceId)
                let pushFcmTokenEncrypted = try credentials.csrfAgent.encrypt(pushFcmToken)
                let serverDeviceGUIDEncrypted = try credentials.csrfAgent.encrypt(serverDeviceGUID)
                
                let settingsEncrypted = try Self.settingsEncrypted(credentials: credentials, loginValue: loginValue, availableSensorType: availableSensorType, isSensorEnabled: isSensorEnabled)
                
                self.init(token: credentials.token, payload: .init(cryptoVersion: cryptoVersion, pushDeviceId: pushDeviceIdEncrypted, pushFcmToken: pushFcmTokenEncrypted, serverDeviceGUID: serverDeviceGUIDEncrypted, settings: settingsEncrypted))
            }
            
            static func settingsEncrypted(credentials: SessionCredentials, loginValue: String, availableSensorType: BiometricSensorType?, isSensorEnabled: Bool) throws -> [Settings] {
                
                let loginValueEncrypted = try credentials.csrfAgent.encrypt(loginValue)
                let typePinEncrypted = try credentials.csrfAgent.encrypt(SettingsType.pin.rawValue)
                let typeFaceEncrypted = try credentials.csrfAgent.encrypt(SettingsType.faceId.rawValue)
                let typeTouchEncrypted = try credentials.csrfAgent.encrypt(SettingsType.touchId.rawValue)
                
                if let availableSensorType = availableSensorType {
                    
                    switch availableSensorType {
                    case .face:
                        return [.init(type: typePinEncrypted, value: loginValueEncrypted, isActive: true),
                                .init(type: typeFaceEncrypted, value: loginValueEncrypted, isActive: isSensorEnabled),
                                .init( type: typeTouchEncrypted, value: nil, isActive: false)]
                        
                    case .touch:
                        return [.init(type: typePinEncrypted, value: loginValueEncrypted, isActive: true),
                                .init(type: typeFaceEncrypted, value: nil, isActive: false),
                                .init(type: typeTouchEncrypted, value: loginValueEncrypted, isActive: isSensorEnabled)]
                    }
                    
                } else {
                    
                    return [.init(type: typePinEncrypted, value: loginValueEncrypted, isActive: true),
                            .init(type: typeFaceEncrypted, value: nil, isActive: false),
                            .init(type: typeTouchEncrypted, value: nil, isActive: false)]
                }
            }
        }
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/registration/verifyCode
         */
        struct VerifyCode: ServerCommand {
            
            let token: String
            let endpoint = "/registration/verifyCode"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String
                let verificationCode: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.payload = payload
                self.token = token
            }
        }
    }
}
