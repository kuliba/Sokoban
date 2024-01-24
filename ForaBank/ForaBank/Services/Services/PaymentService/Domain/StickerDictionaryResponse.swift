//
//  StickerDictionaryResponse.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.11.2023.
//

import Foundation

enum StickerDictionaryResponse: Equatable {
    
    case orderForm(StickerOrderForm)
    case deliveryType(DeliveryType)
}

extension StickerDictionaryResponse {
    
    public struct DeliveryType: Equatable {
        
        let main: [Main]
        let serial: String
        
        public init(
            main: [Main],
            serial: String
        ) {
            self.main = main
            self.serial = serial
        }
    }
    
    public struct StickerOrderForm: Equatable {
        
        let header: [Header]
        let main: [Main]
        let footer: [Footer]
        let serial: String
        
        struct Footer: Equatable {}
        
        struct Header: Equatable {
            
            let type: ComponentType
            let data: Data
            
            struct Data: Equatable {
                
                let title: String
                let isFixed: Bool
                
                public init(
                    title: String,
                    isFixed: Bool
                ) {
                    self.title = title
                    self.isFixed = isFixed
                }
            }
            
            public init(
                type: ComponentType,
                data: Data
            ) {
                self.type = type
                self.data = data
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
        
        init(componentType: ResponseMapper._StickerDictionary.ComponentType) {
            
            switch componentType {
            case .citySelector:
                self = .citySelector
                
            case .endSeparator:
                self = .endSeparator
                
            case .officeSelector:
                self = .officeSelector
                
            case .pageTitle:
                self = .pageTitle
                
            case .productInfo:
                self = .productInfo
                
            case .productSelect:
                self = .productSelect
                
            case .selector:
                self = .selector
                
            case .separator:
                self = .separator
                
            case .separatorSubGroup:
                self = .separatorSubGroup
                
            case .textsWithIconHorizontal:
                self = .textsWithIconHorizontal
            }
        }
    }
    
    enum DataType: Equatable {
        
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
        
        init(dataType: ResponseMapper._StickerDictionary.DataType) {
            
            switch dataType {
            case let .banner(banner):
                self = .banner(.init(
                    title: banner.title,
                    subtitle: banner.subtitle,
                    currencyCode: banner.currencyCode,
                    currency: banner.currency,
                    md5hash: banner.md5hash,
                    txtConditionList: banner.txtConditionList.map({
                        
                        Banner.Condition(
                            name: $0.name,
                            description: $0.description,
                            value: $0.value
                        )  
                    }))
                )
                
            case let .citySelector(citySelector):
                self = .citySelector(.init(
                    title: citySelector.title,
                    subtitle: citySelector.subtitle,
                    isCityList: citySelector.isCityList,
                    md5hash: citySelector.md5hash
                ))
                
            case let .hint(hint):
                self = .hint(.init(
                    title: hint.title,
                    md5hash: hint.md5hash,
                    contentCenterAndPull: hint.contentCenterAndPull
                ))
                
            case let .noValid(error):
                self = .noValid(error)
                
            case let .officeSelector(officeSelector):
                self = .officeSelector(.init(
                    title: officeSelector.title,
                    subtitle: officeSelector.subtitle,
                    md5hash: officeSelector.md5hash
                ))
                
            case let .pageTitle(pageTitle):
                self = .pageTitle(.init(
                    title: pageTitle.title,
                    isFixed: pageTitle.isFixed
                ))
                
            case let .product(product):
                self = .product(.init(withoutPadding: product.withoutPadding))
                
            case let .selector(selector):
                self = .selector(.init(
                    title: selector.title,
                    subtitle: selector.subtitle,
                    md5hash: selector.md5hash,
                    list: selector.list.map({
                        StickerDictionaryResponse.Selector.Option(
                            type: .init(responseType: $0.type),
                            md5hash: $0.md5hash,
                            title: $0.title,
                            backgroundColor: $0.backgroundColor,
                            value: $0.value
                        )}))
                )
            case let .separator(separator):
                self = .separator(.init(color: separator.color))
                
            case .separatorGroup:
                self = .separatorGroup
            }
        }
    }
    
    public struct Main: Equatable {
        
        let type: ComponentType
        let data: DataType
    }
    
    struct Selector: Equatable {
        
        let title: String
        let subtitle: String
        let md5hash: String
        let list: [Option]
        
        struct Option: Equatable {
            
            let type: OptionType
            let md5hash: String
            let title: String
            let backgroundColor: String
            let value: Double
            
            enum OptionType: String, Equatable {
                
                case typeDeliveryOffice
                case typeDeliveryCourier
                
                typealias ResponseType = ResponseMapper._StickerDictionary.Selector.Option.OptionType
                
                init(responseType: ResponseType) {
                    
                    switch responseType {
                    case .typeDeliveryCourier:
                        self = .typeDeliveryCourier
                        
                    case .typeDeliveryOffice:
                        self = .typeDeliveryOffice
                        
                    }
                }
            }
        }
    }
    
    struct Product: Equatable {
        
        let withoutPadding: Bool
    }
    
    struct Separator: Equatable {
        
        let color: String
    }
    
    struct Banner: Equatable {
        
        let title: String
        let subtitle: String
        let currencyCode: Int
        let currency: String
        let md5hash: String
        let txtConditionList: [Condition]
        
        struct Condition: Equatable {
            
            let name: String
            let description: String
            let value: Double
        }
    }
    
    struct Hint: Equatable {
        
        let title: String
        let md5hash: String
        let contentCenterAndPull: Bool
    }
    
    struct CitySelector: Equatable {
        
        let title: String
        let subtitle: String
        let isCityList: Bool
        let md5hash: String
    }
    
    struct OfficeSelector: Equatable {
        
        let title: String
        let subtitle: String
        let md5hash: String
    }
}
