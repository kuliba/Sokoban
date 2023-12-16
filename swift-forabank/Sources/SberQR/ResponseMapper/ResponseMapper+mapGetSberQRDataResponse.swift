//
//  ResponseMapper+mapGetSberQRDataResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias GetSberQRDataResult = Result<GetSberQRDataResponse, MappingError>
    
    static func mapGetSberQRDataResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetSberQRDataResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetSberQRDataResponse {
        
        try .init(
            qrcID: data.qrcId,
            parameters: data.parameters.map { try $0.parameter() },
            required: data.required.map(\.required)
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let qrcId: String
        let parameters: [Parameter]
        let required: [Required]
    }
}

private extension ResponseMapper._Data {
    
    struct Parameter: Decodable {
        
        let id: String
        let type: ParameterType
        let value: String?
        let color: Color?
        let title: String?
        let action: Action?
        let filter: Filter?
        let icon: Icon?
        let validationRules: [ValidationRule]?
        let button: Button?
        let placement: Placement?
        
        enum Action: String, Decodable {
            
            case pay = "PAY"
            
            var action: GetSberQRDataResponse.Parameter.Button<GetSberQRDataButtonID>.Action {
                
                switch self {
                case .pay: return .pay
                }
            }
        }
        
        enum Color: String, Decodable {
            
            case red
            
            var buttonColor: GetSberQRDataResponse.Parameter.Button<GetSberQRDataButtonID>.Color {
                
                switch self {
                case .red: return .red
                }
            }
        }
        
        enum ParameterType: String, Decodable {
            
            case amount        = "AMOUNT"
            case button        = "BUTTON"
            case dataString    = "DATA_STRING"
            case header        = "HEADER"
            case info          = "INFO"
            case productSelect = "PRODUCT_SELECT"
        }
        
        struct Button: Decodable {
            
            let title: String
            let action: Action
            let color: Color
            
            var amountButton: GetSberQRDataResponse.Parameter.Amount.Button {
                
                .init(
                    title: title,
                    action: action.action,
                    color: color.amountColor
                )
            }
            
            enum Action: String, Decodable {
                
                case paySberQR = "PAY_SBER_QR"
                
                var action: GetSberQRDataResponse.Parameter.Amount.Action {
                    
                    switch self {
                    case .paySberQR: return .paySberQR
                    }
                }
            }
            
            enum Color: String, Decodable {
                
                case red
                
                var amountColor: GetSberQRDataResponse.Parameter.Amount.Color {
                    
                    switch self {
                    case .red: return .red
                    }
                }
            }
        }
        
        struct Filter: Decodable {
            
            let productTypes: [ProductType]
            let currencies: [Currency]
            let additional: Bool
            
            var filter: GetSberQRDataResponse.Parameter.ProductSelect.Filter {
                
                .init(
                    productTypes: productTypes.map(\.productType),
                    currencies: currencies.map(\.currency),
                    additional: additional
                )
            }
            
            enum Currency: String, Decodable {
                
                case rub = "RUB"
                
                var currency: GetSberQRDataResponse.Parameter.ProductSelect.Filter.Currency {
                    
                    switch self {
                    case .rub: return .rub
                    }
                }
            }
            
            enum ProductType: String, Decodable {
                
                case card = "CARD"
                case account = "ACCOUNT"
                
                var productType: GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType {
                    
                    switch self {
                    case .card:    return .card
                    case .account: return .account
                    }
                }
            }
        }
        
        struct Icon: Decodable {
            
            let type: IconType
            let value: String
            
            var icon: GetSberQRDataResponse.Parameter.Info.Icon {
                
                .init(type: type.type, value: value)
            }
            
            enum IconType: String, Decodable {
                
                case local  = "LOCAL"
                case remote = "REMOTE"
                
                var type: GetSberQRDataResponse.Parameter.Info.Icon.IconType {
                    
                    switch self {
                    case .local:  return .local
                    case .remote: return .remote
                    }
                }
            }
        }
        
        enum Placement: String, Decodable {
            
            case bottom = "BOTTOM"
            
            var placement: GetSberQRDataResponse.Parameter.Button<GetSberQRDataButtonID>.Placement {
                
                switch self {
                case .bottom: return .bottom
                }
            }
        }
        
        struct ValidationRule: Decodable {
            
            var rule: GetSberQRDataResponse.Parameter.Amount.ValidationRule {
                
                .init()
            }
        }
        
        struct MappingError: Error {}
        
        func parameter() throws -> GetSberQRDataResponse.Parameter {
            
            switch type {
            case .amount:
                typealias ID = GetSberQRDataResponse.Parameter.Amount.ID
                
                guard let id = ID(rawValue: id),
                      let title,
                      let value = Decimal(string: value ?? "0"),
                      let validationRules,
                      let amountButton = button?.amountButton
                else { throw MappingError() }
                
                return .amount(.init(
                    id: id,
                    value: value,
                    title: title,
                    validationRules: validationRules.map(\.rule),
                    button: amountButton
                ))
                
            case .button:
                guard let id = GetSberQRDataButtonID(rawValue: id),
                      let value,
                      let color = color?.buttonColor,
                      let placement = placement?.placement,
                      let action = action?.action
                else { throw MappingError() }
                
                return
                    .button(.init(
                        id: id,
                        value: value,
                        color: color,
                        action: action,
                        placement: placement
                    ))
                
            case .dataString:
                typealias ID = GetSberQRDataResponse.Parameter.DataString.ID
                
                guard let id = ID(rawValue: id),
                      let value else { throw MappingError() }
                
                return .dataString(.init(id: id, value: value))
                
            case .header:
                typealias ID = GetSberQRDataResponse.Parameter.Header.ID
                
                guard let id = ID(rawValue: id),
                      let value
                else { throw MappingError() }
                
                return .header(.init(id: id, value: value))
                
            case .productSelect:
                typealias ID = GetSberQRDataResponse.Parameter.ProductSelect.ID
                
                guard let title,
                      let filter = filter?.filter
                else { throw MappingError() }
                
                return .productSelect(.init(
                    id: .init(id),
                    value: value,
                    title: title,
                    filter: filter
                ))
                
            case .info:
                typealias ID = GetSberQRDataResponse.Parameter.Info.ID
                
                guard let id = ID(rawValue: id),
                      let value,
                      let title,
                      let icon = icon?.icon
                else { throw MappingError() }
                
                return .info(.init(
                    id: id,
                    value: value,
                    title: title,
                    icon: icon
                ))
            }
        }
    }
    
    enum Required: String, Decodable {
        
        case debit_account
        case payment_amount
        case currency
        
        var required: GetSberQRDataResponse.Required {
            
            switch self {
            case .debit_account:
                return .debitAccount
                
            case .payment_amount:
                return .paymentAmount
                
            case .currency:
                return .currency
            }
        }
    }
}
