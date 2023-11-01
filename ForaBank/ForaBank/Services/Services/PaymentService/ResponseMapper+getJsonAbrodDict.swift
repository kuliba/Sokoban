//
//  ResponseMapper+getJsonAbrodDict.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 01.11.2023.
//

import Foundation

enum ResponseMapper {}

extension ResponseMapper {
    
    typealias StickerDictionaryResult = Result<StickerDictionary, StickerDictionaryError>
    
    static func mapStickerDictionaryResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> StickerDictionaryResult {
        
        do {
            switch httpURLResponse.statusCode {
                
            case 200:
                
                if data.isEmpty {
                    
                    return .failure(.invalidData(
                        statusCode: httpURLResponse.statusCode,
                        data: data
                    ))
                    
                } else {
                    
                    let stickerDictionary = try JSONDecoder().decode(StickerDictionary.self, from: data)
                    return .success(stickerDictionary)
                }
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
                
            }
            
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode, data: data
            ))
            
        }
    }
    
    enum StickerDictionaryError: Error {
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
    
    enum StickerDictionary: Decodable {
        
        case OrderForm(StickerOrderForm)
        case DeliveryOffice(DeliveryOffice)
        case DeliveryCourier(DeliveryCourier)
    }
    
    struct StickerOrderForm: Decodable {
        
        let header: [Header]
        let main: [Main]
        let footer: [Footer]
        let serial: String
        
        struct Footer: Decodable {}
        
        struct Header: Decodable {
            
            let type: ComponentType
            let data: Data
            
            struct Data: Decodable {
                
                let title: String
                let isFixed: Bool
            }
        }
        
    }
    
    struct DeliveryOffice: Decodable {
        
        let main: [Main]
        let serial: String
    }
    
    struct DeliveryCourier: Decodable {
        
        let main: [Main]
        let serial: String
    }
    
    struct ServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
    }
    
    struct Main: Decodable {
        
        let type: ComponentType
        let data: Data
        
        enum DataType {
            
            case hint(Hint)
            case banner(Banner)
            case product(Product)
            case separator(Separator)
            case selector(Selector)
            case citySelector(CitySelector)
            case officeSelector(OfficeSelector)
        }
        
        struct Selector: Decodable {
            
            let title: String
            let subtitle: String
            let md5hash: String
            let list: [Option]
            
            struct Option: Decodable {
                
                let type: OptionType
                let md5hash: String
                let title: String
                let backgroundColor: String
                let value: Double
                
                enum OptionType: String, Decodable {
                    
                    case typeDeliveryOffice
                    case typeDeliveryCourier
                }
            }
        }
        
        struct Product: Decodable {
            
            let withoutPadding: Bool
        }
        
        struct Separator: Decodable {
            
            let color: String
        }
        
        struct Banner: Decodable {
            
            let title: String
            let subtitle: String
            let currencyCode: Int
            let currency: String
            let md5hash: String
            let txtConditionList: [Condition]
            
            struct Condition: Decodable {
                
                let name: String
                let description: String
                let value: Double
                
                enum CodingKeys: String, CodingKey {
                    
                    case name, value
                    case description = "descriptoin"
                }
            }
        }
        
        struct Hint: Decodable {
            
            let md5hash: String
            let title: String
            let contentCenterAndPull: Bool
        }
        
        struct CitySelector {
            
            let title: String
            let subtitle: String
            let isCityList: Bool
            let md5hash: String
        }
        
        struct OfficeSelector {
            
            let title: String
            let subtitle: String
            let isCityList: Bool
            let md5hash: String
        }
    }
    
    enum ComponentType: String, Decodable {
        
        case pageTitle = "PAGE_TITLE"
        case textsWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case productInfo = "PRODUCT_INFO"
        case productSelect = "PRODUCT_SELECT"
        case separator = "SEPARATOR_START_OPERATOR"
        case selector = "VERTICAL_SELECTOR"
        case citySelector = "CITY_SELECTOR"
        case officeSelector = "OFFICE_SELECTOR"
    }
}

