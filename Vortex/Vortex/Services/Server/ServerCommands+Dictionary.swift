//
//  ServerCommands+Dictionary.swift
//  ForaBank
//
//  Created by Дмитрий on 24.01.2022.
//

import Foundation
import ServerAgent
import SwiftUI

extension ServerCommands {
    
    enum DictionaryController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getAnywayOperatorsList
         */
        struct GetAnywayOperatorsList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getAnywayOperatorsList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getBanks
         */
        struct GetBanks: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getBanks"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getPrefferdBanksList
         */
        struct GetPrefferdBanksList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/v1/getPrefferedBanksRequisitesList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: PrefferedBanksList?
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getCountries
         */
        struct GetCountries: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getCountries"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getCurrencyWalletList_v3
        */
        struct GetCurrencyWalletList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getCurrencyWalletList_V3"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CurrencyWalletListData?
                
                struct CurrencyWalletListData: Decodable, Equatable {
                    
                    let list: [CurrencyWalletData]
                    let serial: String
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getCentralBankRates
        */
        struct GetCentralBankRates: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getCentralBankRates"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CentralBankRatesList?
                
                struct CentralBankRatesList: Decodable, Equatable {
                    
                    let ratesCb: [CentralBankRatesData]
                }
            }
            
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getCurrencyList
         */
        struct GetCurrencyList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getCurrencyList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getFMSListUsingGET
         */
        struct GetFMSList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getFMSList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: FMSListData?
                
                struct FMSListData: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case fmsList = "FMSList"
                        case id
                        case puref
                        case serial
                    }
                    
                    let fmsList: [FMSData]
                    let id: String
                    let puref: String
                    let serial: String
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getFSSPDebtList
         */
        struct GetFSSPDebtList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getFSSPDebtList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
                
                struct Data: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case fsspDebtList = "FSSPDebtList"
                        case id
                        case puref
                        case serial
                    }
                    
                    let fsspDebtList: [FSSPDebtData]
                    let id: String
                    let puref: String
                    let serial: String
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getFSSPDocumentList
         */
        struct GetFSSPDocumentList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getFSSPDocumentList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
                
                struct Data: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case fsspDocumentList = "FSSPDocumentList"
                        case id
                        case puref
                        case serial
                    }
                    
                    let fsspDocumentList: [FSSPDocumentData]
                    let id: String
                    let puref: String
                    let serial: String
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getFTSListUsingGET
         */
        struct GetFTSList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getFTSList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: FTSListData?
                
                struct FTSListData: Decodable, Equatable {
                    
                    enum CodingKeys : String, CodingKey {
                        
                        case ftsList = "FTSList"
                        case id
                        case puref
                        case serial
                    }
                    
                    let ftsList: [FTSData]
                    let id: String
                    let puref: String
                    let serial: String
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getFullBankInfoList
         */
        struct GetFullBankInfoList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getFullBankInfoList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            internal init(token: String, bic: String = "", name: String? = nil, engName: String? = nil, type: String? = nil, account: String? = nil, swift: String? = nil, serviceType: String? = nil, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getMobileList
         */
        struct GetMobileList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getMobileList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getMosParkingList
         */
        struct GetMosParkingList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getMosParkingList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/dict/getPaymentSystemList
         */
        struct GetPaymentSystemList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getPaymentSystemList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getProductCatalogListUsingGET
         */
        struct GetProductCatalogList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getProductCatalogList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
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
            
            init(token: String, serial: String?) {
                
                self.token = token
                
                if let serial = serial {
                    
                    self.parameters = [.init(name: "serial", value: serial)]
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getProductCatalogImageUsingGET
         */
        struct GetProductCatalogImage: ServerDownloadCommand {
            
            let token: String
            let endpoint: String
            let method: ServerCommandMethod = .get
            let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
            
            struct Payload: Encodable {}
            
            init(token: String, endpoint: String) {
                
                self.token = token
                self.endpoint = "/" + endpoint
            }
        }
        
        struct GetBannersMyProductListWithSticker: ServerCommand {
            
            let token: String
            let endpoint = "/dict/v1/getBannersMyProductList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: StickerResponseData?
                let errorMessage: String?
                
                struct StickerResponseData: Codable, Equatable {
                    
                    let stickerCardData: [StickerBannersMyProductList]
                    let serial: String
                    
                    private enum CodingKeys: String, CodingKey {
                        
                        case stickerCardData = "cardBannerList"
                        case serial
                    }
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/getBannerCatalogListUsingGet
         */
        struct GetBannerCatalogList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getBannerCatalogList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: BannerCatalogData?
                let errorMessage: String?
                
                struct BannerCatalogData: Codable, Equatable {
                    
                    let bannerCatalogList: [BannerCatalogListData]
                    let serial: String
                    
                    private enum CodingKeys: String, CodingKey {
                        
                        case bannerCatalogList = "BannerCatalogList"
                        case serial
                    }
                }
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController//dict/getBannerCatalogImageUsingGet
         */
        struct GetBannerCatalogImage: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/dict/getBannerCatalogImage"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
            
            struct Payload: Encodable {}
            
            init(token: String, imageEndpoint: String) {
                
                self.token = token
                
                var parameters = [ServerCommandParameter]()
                
                parameters.append(.init(name: "image", value: imageEndpoint))
                self.parameters = parameters
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getImageList
         */
        //TODO: - tests
        struct GetSvgImageList: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getSvgImageList"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let md5HashList: [String]
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: SvgImageListData?
                
                struct SvgImageListData: Codable, Equatable {
                    
                    let svgImageList: [ListItemData]
                    
                    struct ListItemData: Codable, Equatable {
                        
                        let md5hash: String
                        let svgImage: SVGImageData
                    }
                }
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getCountriesWithServices
         */
        struct GetCountriesWithServices: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getCountriesWithServices"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
                
                struct Data: Decodable, Equatable {
                    
                    let serial: String
                    let list: [CountryWithServiceData]
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
         http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getImageList
         */
        struct GetDictionaryAnywayOperators: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getDictionaryAnywayOperators"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
                
                struct Data: Decodable, Equatable {
                    
                    let list: [List]
                    
                    struct List: Codable, Equatable {
                        
                        let code: String
                        let codeUI: String
                        let dictionaryList: [AnywayOperatorData]
                    }
                }
            }
            
            init(token: String, code: String, codeParent: String?) {
                
                self.token = token
                    
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "code", value: code))
                
                if let codeParent = codeParent {
                    
                    parameters.append(.init(name: "codeParent", value: codeParent))
                }
                
                self.parameters = parameters
            }
        }
        
    
        //https://../DictionaryController/getClientInformData
     
        struct GetClientInformData: ServerCommand {
            
            let token: String
            let endpoint = "/dict/v1/getClientInformData"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
                
            struct Payload: Encodable {}
                
            struct Response: ServerResponse {
                    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ClientInformData?
            }
                
            init(token: String, serial: String?) {
                    
                self.token = token
                    
                if let serial = serial{
                        
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
    
