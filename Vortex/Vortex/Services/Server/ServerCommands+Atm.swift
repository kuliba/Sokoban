//
//  ServerCommands+Atm.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum AtmController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmList
         */
        struct GetAtmList: ServerCommand {
            
            let token: String
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
            
            init(token: String, version: Int) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "version", value: "\(version)"))
                self.parameters = parameters
            }
            
            init(token: String, serial: String?) {
                 
                self.init(token: token, version: 0)
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmServiceList
         */
        struct GetAtmServiceList: ServerCommand {
            
            let token: String
            let endpoint = "/atm/v2/getAtmServiceList"
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
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getAtmTypeList
         */
        struct GetAtmTypeList: ServerCommand {
            
            let token: String
            let endpoint = "/atm/v2/getAtmTypeList"
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
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AtmController/getMetroStationList
         */
        struct GetMetroStationList: ServerCommand {
            
            let token: String
            let endpoint = "/atm/v2/getMetroStationList"
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
        
        /*
         http://192.168.50.113:8080/swagger-ui/index.html#/AtmController/getCity
         */
        
        struct GetCityList: ServerCommand {
            
            let token: String
            let endpoint = "/atm/v3/getCityList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmCityListData?
                
                struct AtmCityListData: Decodable, Equatable {
                    
                    let serial: String
                    let list: [AtmCityData]
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
        
        /*
         http://192.168.50.113:8080/swagger-ui/index.html#/AtmController/getRegion
         */
        
        struct GetRegionList: ServerCommand {
            
            let token: String
            let endpoint = "/atm/v2/getRegionList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AtmRegionListData?
                
                struct AtmRegionListData: Decodable, Equatable {
                    
                    let serial: String
                    let list: [AtmRegionData]
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
