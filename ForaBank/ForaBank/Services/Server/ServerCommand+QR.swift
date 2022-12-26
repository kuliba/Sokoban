//
//  ServerCommand+QR.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.10.2022.
//

import Foundation

extension ServerCommands {
    
    enum QRController {
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/qr-controller/setQrFailData
         */
        
        struct SetQRFailData: ServerCommand {
 
            let token: String
            let endpoint = "/rest/setQrFailData"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            typealias Payload = QRMapping.FailData
                        
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
        http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getPaymentsMapping
         */
        
        struct GetPaymentsMapping: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getPaymentsMapping"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil

            struct Payload: Encodable {}

            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: QRMappingData?

                struct QRMappingData: Decodable, Equatable {

                    let serial: String
                    let qrMapping: QRMapping
                }
            }

            init(token: String, serial: String?) {

                self.token = token
                
                if let serial = serial {
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
    }
    
}
