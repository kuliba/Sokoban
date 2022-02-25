//
//  ServerCommands+Dictionary.swift
//  ForaBank
//
//  Created by Дмитрий on 24.01.2022.
//

import Foundation

extension ServerCommands {
    
    enum DictionaryController {
 
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getAnywayOperatorsList
         */
        struct GetAnywayOperatorsList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getAnywayOperatorsList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: AnywayOperatorGroupData?
                
                struct AnywayOperatorGroupData: Decodable, Equatable {
                    
                    let operatorGroupList: [OperatorGroupData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getBanks
         */
        struct GetBanks: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getBanks"
            let method: ServerCommandMethod = .get
            var parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BankListData?
                
                struct BankListData: Decodable, Equatable {
                    
                    let banksList: [BankData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getCountries
         */
        struct GetCountries: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getCountries"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CountryListData?
                
                struct CountryListData: Decodable, Equatable {
                    
                    let countriesList: [CountryData]
                    let serial: String
                }
            }
                    
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getCurrencyList
         */
        struct GetCurrencyList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getCurrencyList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CurrencyListData?
                
                struct CurrencyListData: Decodable, Equatable {
                    
                    let currencyList: [CurrencyData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getFMSListUsingGET
         */
        struct GetFMSList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getFMSList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: FMSListData?
                
                struct FMSListData: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case fmsList = "FMSList"
                        case serial
                    }
                    
                    let fmsList: [FMSData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getFSSPListUsingGET
         */
        struct GetFSSPList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getFSSPList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: FSSPListData?
                
                struct FSSPListData: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case fsspList = "FSSPList"
                        case serial
                    }
                    
                    let fsspList: [FSSPData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getFTSListUsingGET
         */
        struct GetFTSList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getFTSList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: FTSListData?
                
                struct FTSListData: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case ftsList = "FTSList"
                        case serial
                    }
                    
                    let ftsList: [FTSData]
                    let serial: String
                }
            }
            
            internal init(serial: String?) {
                
                if let serial = serial{
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getFullBankInfoList
         */
        struct GetFullBankInfoList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getFullBankInfoList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BankFullInfoListData?
                
                struct BankFullInfoListData: Decodable, Equatable {
                    
                    let bankFullInfoList: [BankFullInfoData]
                    let serial: String
                }
            }
            
            internal init(bic: String, name: String?, engName: String?, type: String?, account: String?, swift: String?, serviceType: String?, serial: String?) {
                
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "bic", value: bic))
                
                if let name = name {
                    
                    parameters.append(.init(name: "name", value: name))
                }
                
                if let engName = engName {
                    
                    parameters.append(.init(name: "engName", value: engName))
                }
                
                if let type = type {
                    
                    parameters.append(.init(name: "type", value: type))
                }
                
                if let account = account {
                    
                    parameters.append(.init(name: "account", value: account))
                }
                
                if let swift = swift {
                    
                    parameters.append(.init(name: "swift", value: swift))
                }
                
                if let serviceType = serviceType {
                    
                    parameters.append(.init(name: "serviceType", value: serviceType))
                }
                
                if let serial = serial {
                    
                    parameters.append(.init(name: "serial", value: serial))
                }
                self.parameters = parameters
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getMobileList
         */
        struct GetMobileList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getMobileList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: MobileListData?
                
                struct MobileListData: Decodable, Equatable {
                    
                    let mobileList: [MobileData]
                    let serial: String
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getMosParkingList
         */
        struct GetMosParkingList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getMosParkingList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: MosParkingListData?
                
                struct MosParkingListData: Decodable, Equatable {
                    
                    let mosParkingList: [MosParkingData]
                    let serial: String
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/dict/getPaymentSystemList
         */
        struct GetPaymentSystemList: ServerCommand {
            
            let token: String? = nil
            let endpoint = "/dict/getPaymentSystemList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                var data: PaymentSystemListData?
                
                struct PaymentSystemListData: Decodable, Equatable {
                    
                    var paymentSystemList: [PaymentSystemData]
                    let serial: String
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
          https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getProductCatalogListUsingGET
          */
         struct GetProductCatalogList: ServerCommand {

             var token: String? = nil
             let endpoint = "/dict/getProductCatalogList"
             let method: ServerCommandMethod = .get
             let parameters: [ServerCommandParameter]? = nil
             var payload: Payload? = nil
             let timeout: TimeInterval? = nil

             struct Payload: Encodable {}

             struct Response: ServerResponse {
                 
                 let statusCode: ServerStatusCode
                 let data: ProductCatalog?
                 let errorMessage: String?
                 
                 struct ProductCatalog: Decodable, Equatable {
                     
                     let productCatalogList: [CatalogProductData]
                     let serial: String
                     
                     enum CodingKeys : String, CodingKey {
                         
                         case productCatalogList = "ProductCatalogList"
                         case serial
                     }
                 }
             }
         }
         
         /*
          https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getProductCatalogImageUsingGET
          */
         struct GetProductCatalogImage: ServerDownloadCommand {

             var token: String? = nil
             let endpoint = "/dict/getProductCatalogList"
             let method: ServerCommandMethod = .get
             let parameters: [ServerCommandParameter]?
             var payload: Payload? = nil
             let timeout: TimeInterval? = nil

             struct Payload: Encodable {}

             internal init(imageEndpoint: String) {

                 self.parameters = [ServerCommandParameter(name: "image", value: imageEndpoint)]
             }
         }
     }
 }
