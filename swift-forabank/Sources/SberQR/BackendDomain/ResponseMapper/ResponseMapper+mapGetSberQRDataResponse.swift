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
        
        let id: ID
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

private extension ResponseMapper._Data.Parameter {
    
    enum Action: String, Decodable {
        
        case pay = "PAY"
        
        var action: GetSberQRDataResponse.Parameter.Action {
            
            switch self {
            case .pay: return .pay
            }
        }
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
            
            var amountColor: Parameters.Color {
                
                switch self {
                case .red: return .red
                }
            }
        }
    }
    
    enum Color: String, Decodable {
        
        case red
        
        var buttonColor: Parameters.Color {
            
            switch self {
            case .red: return .red
            }
        }
    }
    
    struct Filter: Decodable {
        
        let productTypes: [ProductType]
        let currencies: [Currency]
        let additional: Bool
        
        typealias Filter = GetSberQRDataResponse.Parameter.ProductSelect.Filter
        
        var filter: Filter {
            
            .init(
                productTypes: productTypes.map(\.productType),
                currencies: currencies.map(\.currency),
                additional: additional
            )
        }
        
        enum Currency: String, Decodable {
            
            case rub = "RUB"
            
            var currency: Filter.Currency {
                
                switch self {
                case .rub: return .rub
                }
            }
        }
        
        enum ProductType: String, Decodable {
            
            case card = "CARD"
            case account = "ACCOUNT"
            
            var productType: Filter.ProductType {
                
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
    
    enum ID: String, Decodable {
        
        case paymentAmount = "payment_amount"
        case buttonPay = "button_pay"
        case currency
        case title
        case amount, brandName, recipientBank
        case debit_account
        
        var amountID: GetSberQRDataIDs.AmountID? {
            
            switch self {
            case .paymentAmount: return .paymentAmount
            default:             return .none
            }
        }
        
        var buttonID: GetSberQRDataIDs.ButtonID? {
            
            switch self {
            case .buttonPay: return .buttonPay
            default:         return .none
            }
        }
        
        var dataStringID: GetSberQRDataIDs.DataStringID? {
            
            switch self {
            case .currency: return .currency
            default:        return .none
            }
        }
        
        var headerID: GetSberQRDataIDs.HeaderID? {
            
            switch self {
            case .title: return .title
            default:     return .none
            }
        }
        
        var infoID: GetSberQRDataIDs.InfoID? {
            
            switch self {
            case .amount:        return .amount
            case .brandName:     return .brandName
            case .recipientBank: return .recipientBank
            default:             return .none
            }
        }
        
        var productSelectID: GetSberQRDataIDs.ProductSelectID? {
            
            switch self {
            case .debit_account: return .debit_account
            default:             return .none
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
    
    enum Placement: String, Decodable {
        
        case bottom = "BOTTOM"
        
        var placement: Parameters.Placement {
            
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
}

private extension ResponseMapper._Data.Parameter {
    
    struct MappingError: Error {}
    
    func parameter() throws -> GetSberQRDataResponse.Parameter {
        
        switch type {
        case .amount:
            typealias ID = GetSberQRDataIDs.AmountID
            
            guard let id = id.amountID,
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
            typealias ID = GetSberQRDataIDs.ButtonID
            
            guard let id = id.buttonID,
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
            typealias ID = GetSberQRDataIDs.DataStringID
            
            guard let id = id.dataStringID,
                  let value else { throw MappingError() }
            
            return .dataString(.init(id: id, value: value))
            
        case .header:
            typealias ID = GetSberQRDataIDs.HeaderID
            
            guard let id = id.headerID,
                  let value
            else { throw MappingError() }
            
            return .header(.init(id: id, value: value))
            
        case .info:
            typealias ID = GetSberQRDataIDs.InfoID
            
            guard let id = id.infoID,
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
            
        case .productSelect:
            typealias ID = GetSberQRDataIDs.ProductSelectID
            
            guard let id = id.productSelectID,
                  let title,
                  let filter = filter?.filter
            else { throw MappingError() }
            
            return .productSelect(.init(
                id: id,
                value: value,
                title: title,
                filter: filter
            ))
        }
    }
}
