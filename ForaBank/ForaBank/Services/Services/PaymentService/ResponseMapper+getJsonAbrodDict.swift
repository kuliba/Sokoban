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
        
        case orderForm(StickerOrderForm)
        case deliveryOffice(DeliveryOffice)
        case deliveryCourier(DeliveryCourier)
        case noValid(String)
        
        init(from decoder: Decoder) throws {
            
            enum CodingKeys: CodingKey {
                
                case data
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let data = try? container.decode(StickerOrderForm.self, forKey: .data) {
                self = .orderForm(data)
                
            } else if let data = try? container.decode(DeliveryOffice.self, forKey: .data) {
                self = .deliveryOffice(data)
                
            } else if let data = try? container.decode(DeliveryCourier.self, forKey: .data) {
                self = .deliveryCourier(data)
                
            } else {
                
                self = .noValid("not valid data")
            }
        }
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
        let data: DataType
        
        enum DataType: Decodable {
            
            case hint(Hint)
            case banner(Banner)
            case product(Product)
            case separator(Separator)
            case selector(Selector)
            case citySelector(CitySelector)
            case officeSelector(OfficeSelector)
            case pageTitle(StickerOrderForm.Header.Data)
            case noValid(String)
            
            init(from decoder: Decoder) throws {
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try? container.decode(ComponentType.self, forKey: .type)
                
                switch type {
                case .citySelector:
                    let data = try container.decode(CitySelector.self, forKey: .data)
                    self = .citySelector(data)
                    
                case .endSeparator:
                    let data = try container.decode(Separator.self, forKey: .data)
                    self = .separator(data)
                    
                case .officeSelector:
                    let data = try container.decode(OfficeSelector.self, forKey: .data)
                    self = .officeSelector(data)
                    
                case .pageTitle:
                    let data = try container.decode(StickerOrderForm.Header.Data.self, forKey: .data)
                    self = .pageTitle(data)
                    
                case .productInfo:
                    let data = try container.decode(Banner.self, forKey: .data)
                    self = .banner(data)
                    
                case .productSelect:
                    let data = try container.decode(Product.self, forKey: .data)
                    self = .product(data)
                    
                case .selector:
                    let data = try container.decode(Selector.self, forKey: .data)
                    self = .selector(data)
                    
                case .separator:
                    let data = try container.decode(Separator.self, forKey: .data)
                    self = .separator(data)
                    
                case .separatorSubGroup:
                    let data = try container.decode(Separator.self, forKey: .data)
                    self = .separator(data)
                    
                case .textsWithIconHorizontal:
                    let data = try container.decode(Hint.self, forKey: .data)
                    self = .hint(data)
                    
                case .none:
                    self = .noValid("could not decode data")
                }
            }
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
        
        struct CitySelector: Decodable {
            
            let title: String
            let subtitle: String
            let isCityList: Bool
            let md5hash: String
            let list: [String?]
        }
        
        struct OfficeSelector: Decodable {
            
            let title: String
            let subtitle: String
            let isCityList: Bool
            let md5hash: String
            let list: [String?]
        }
    }
    
    enum ComponentType: String, Decodable, CodingKey {
        
        case pageTitle = "PAGE_TITLE"
        case textsWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case productInfo = "PRODUCT_INFO"
        case productSelect = "PRODUCT_SELECT"
        case separator = "SEPARATOR_START_OPERATOR"
        case selector = "VERTICAL_SELECTOR"
        case citySelector = "CITY_SELECTOR"
        case officeSelector = "OFFICE_SELECTOR"
        case endSeparator = "SEPARATOR_END_OPERATOR"
        case separatorSubGroup = "SEPARATOR_FIELD_SUB_GROUP"
    }
}

