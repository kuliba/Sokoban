//
//  ServerCommands+PushDevice.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum PushDeviceController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PushDeviceController/registerPushDeviceForUserUsingPOST
         */
        struct RegisterPushDeviceForUser: ServerCommand {

            let token: String?
            let endpoint = "/push_device_user/registerPushDeviceForUser"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: BasePayload?
            let timeout: TimeInterval? = nil
  
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
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PushDeviceController/installPushDeviceUsingPOST
         */
        struct InstallPushDevice: ServerCommand {

            let token: String?
            let endpoint = "/push_device/installPushDevice"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let cryptoVersion: String
                let model: String
                let operationSystem: String = "IOS"
                let pushDeviceId: String
                let pushFcmToken: String
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PushDeviceController/uninstallPushDeviceUsingPOST
         */
        struct UninstallPushDevice: ServerCommand {

            let token: String?
            let endpoint = "/push_device/uninstallPushDevice"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: BasePayload?
            let timeout: TimeInterval? = nil
            
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
            
            let cryptoVersion: String
            let pushDeviceId: String
            let pushFcmToken: String
        }
    }
}
