//
//  StickerDictionary.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.11.2023.
//

import Foundation

extension ResponseMapper {
    
    enum _StickerDictionary: Decodable {
        
        case orderForm(StickerOrderForm)
        case deliveryType(DeliveryType)
        
        init(from decoder: Decoder) throws {
            
            enum CodingKeys: CodingKey {
                
                case data
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let data = try? container.decode(StickerOrderForm.self, forKey: .data) {
                self = .orderForm(data)
                
            } else {
                let data = try container.decode(DeliveryType.self, forKey: .data)
                self = .deliveryType(data)
                
            }
        }
    }
}
//MARK: StickerOrderForm
extension ResponseMapper._StickerDictionary {
    
    struct DeliveryType: Decodable {
        
        let main: [Main]
        let serial: String
    }
    
    public struct StickerOrderForm: Decodable {
        
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
        
        public init(
            header: [Header],
            main: [Main],
            footer: [Footer],
            serial: String
        ) {
            self.header = header
            self.main = main
            self.footer = footer
            self.serial = serial
        }
    }
    
    enum ComponentType: String, Decodable, CodingKey {
        
        case pageTitle = "PAGE_TITLE"
        case textsWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case productInfo = "PRODUCT_INFO"
        case productSelect = "PRODUCT_SELECT"
        case selector = "VERTICAL_SELECTOR"
        case citySelector = "CITY_SELECTOR"
        case officeSelector = "OFFICE_SELECTOR"
        case separator = "SEPARATOR_START_OPERATOR"
        case endSeparator = "SEPARATOR_END_OPERATOR"
        case separatorSubGroup = "SEPARATOR_FIELD_SUB_GROUP"
    }
    
    enum DataType: Decodable {
        
        case hint(Hint)
        case banner(Banner)
        case product(Product)
        case separator(Separator)
        case separatorGroup
        case selector(Selector)
        case citySelector(CitySelector)
        case officeSelector(OfficeSelector)
        case pageTitle(StickerOrderForm.Header.Data)
        case noValid(String)
    }
}

//MARK: Main
extension ResponseMapper._StickerDictionary {
    
    struct Main: Decodable {
        
        let type: ComponentType
        let data: DataType
        
        private enum CodingKeys: CodingKey {
            
            case type
            case data
        }
        
        init(
            type: ComponentType,
            data: DataType
        ) {
            self.type = type
            self.data = data
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(ComponentType.self, forKey: .type)
            
            switch type {
            case .citySelector:
                let citySelector = try container.decode(CitySelector.self, forKey: .data)
                data = .citySelector(citySelector)
                
            case .endSeparator:
                let endSeparator = try container.decode(Separator.self, forKey: .data)
                data = .separator(endSeparator)
                
            case .officeSelector:
                let officeSelector = try container.decode(OfficeSelector.self, forKey: .data)
                data = .officeSelector(officeSelector)
                
            case .pageTitle:
                let pageTitle = try container.decode(StickerOrderForm.Header.Data.self, forKey: .data)
                data = .pageTitle(pageTitle)
                
            case .productInfo:
                let productInfo = try container.decode(Banner.self, forKey: .data)
                data = .banner(productInfo)
                
            case .productSelect:
                let productSelect = try container.decode(Product.self, forKey: .data)
                data = .product(productSelect)
                
            case .selector:
                let selector = try container.decode(Selector.self, forKey: .data)
                data = .selector(selector)
                
            case .separator:
                let separator = try container.decode(Separator.self, forKey: .data)
                data = .separator(separator)
                
            case .separatorSubGroup:
                data = .separatorGroup
                
            case .textsWithIconHorizontal:
                let textsWithIconHorizontal = try container.decode(Hint.self, forKey: .data)
                data = .hint(textsWithIconHorizontal)
            }
        }
    }
}

//MARK: Component's

extension ResponseMapper._StickerDictionary {
    
    struct Selector: Decodable {
        
        let title: String
        let subtitle: String
        let md5hash: String
        let list: [Option]
        
        private enum CodingKeys: String, CodingKey {
            
            case title, md5hash, list
            case subtitle = "subTitle"
        }
        
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
        
        private enum CodingKeys: String, CodingKey {
            
            case title, currencyCode, currency, md5hash, txtConditionList
            case subtitle = "subTitle"
        }
        
        struct Condition: Decodable {
            
            let name: String
            let description: String
            let value: Double
        }
    }
    
    struct Hint: Decodable {
        
        let title: String
        let md5hash: String
        let contentCenterAndPull: Bool
    }
    
    struct CitySelector: Decodable {
        
        let title: String
        let subtitle: String
        let isCityList: Bool
        let md5hash: String
        
        private enum CodingKeys: String, CodingKey {
            
            case title, isCityList, md5hash
            case subtitle = "subTitle"
        }
        
        init(
            title: String,
            subtitle: String,
            isCityList: Bool,
            md5hash: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.isCityList = isCityList
            self.md5hash = md5hash
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decode(String.self, forKey: .subtitle)
            isCityList = try container.decode(Bool.self, forKey: .isCityList)
            md5hash = try container.decode(String.self, forKey: .md5hash)
        }
    }
    
    struct OfficeSelector: Decodable {
        
        let title: String
        let subtitle: String
        let md5hash: String
        
        internal init(
            title: String,
            subtitle: String,
            md5hash: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.md5hash = md5hash
        }
        
        private enum CodingKeys: String, CodingKey {
            
            case title, md5hash
            case subtitle = "subTitle"
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decode(String.self, forKey: .subtitle)
            md5hash = try container.decode(String.self, forKey: .md5hash)
        }
    }
}
