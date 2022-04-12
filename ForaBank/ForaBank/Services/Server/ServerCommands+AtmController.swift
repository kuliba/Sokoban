//
//  ServerCommands+AtmController.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

extension ServerCommands {
    
    enum AtmController {

        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmList
         */
        struct GetAtmList: ServerCommand {

            let endpoint = "/atm/v2/getAtmList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
                        
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmListData?
                
                struct AtmListData: Decodable, Equatable {
                    
                    let version: Int
                    let list: [AtmData]
                }
            }
            
            internal init(version: Int) {

                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "version", value: "\(version)"))
                self.parameters = parameters
            }
            
            internal init(serial: String?) {

                if let serial = serial, let version = Int(serial) {
                    
                    self.init(version: version)
                    
                } else {
                    
                    self.init(version: 0)
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmServiceList
         */
        struct GetAtmServiceList: ServerCommand {

            let endpoint = "/atm/getAtmServiceList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
                        
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmServiceListData?
                
                struct AtmServiceListData: Decodable, Equatable {
                    
                    let serial: String
                    let list: [AtmServiceData]
                }
            }
            
            internal init(serial: String?) {

                if let serial = serial {
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmTypeList
         */
        struct GetAtmTypeList: ServerCommand {

            let endpoint = "/atm/getAtmTypeList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
                        
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmTypeListData?
                
                struct AtmTypeListData: Decodable, Equatable {
                    
                    let serial: String
                    let list: [AtmTypeData]
                }
            }
            
            internal init(serial: String?) {

                if let serial = serial {
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getMetroStationList
         */
        struct GetMetroStationList: ServerCommand {

            let endpoint = "/atm/getMetroStationList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
                        
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmMetroStationListData?
                
                struct AtmMetroStationListData: Decodable, Equatable {
                    
                    let serial: String
                    let list: [AtmMetroStationData]
                }
            }
            
            internal init(serial: String?) {

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
