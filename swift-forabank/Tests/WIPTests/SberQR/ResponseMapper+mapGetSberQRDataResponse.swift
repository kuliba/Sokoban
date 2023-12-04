//
//  ResponseMapper+mapGetSberQRDataResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetSberQRDataResult = Result<GetSberQRDataResponse, GetSberQRDataError>
    
    static func mapGetSberQRDataResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) throws -> GetSberQRDataResult {
        
        do {
            
            let response = try JSONDecoder().decode(_Response.self, from: data)
            
            switch (httpURLResponse.statusCode, response.errorMessage, response.data) {
            case let (200, .none, .some(data)):
                return .success(data.response)
                
            case let (_, .some(errorMessage), .none):
                return .failure(.server(
                    statusCode: response.statusCode,
                    errorMessage: errorMessage
                ))
                
            default:
                struct InvalidResponseError: Error {}
                throw InvalidResponseError()
            }
            
        } catch {
            return .failure(.invalid(statusCode: httpURLResponse.statusCode, data: data))
        }
    }
}

extension ResponseMapper {
    
    struct _Response: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: _Data?
        
        struct _Data: Decodable {
            
            let qrcId: String
            let parameters: [Parameter]
            let required: [Required]
            
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
                    
                    var action: GetSberQRDataResponse.Parameter.Button.Action {
                        
                        switch self {
                        case .pay:
                            return .pay
                        }
                    }
                }
                
                enum Color: String, Decodable {
                    
                    case red
                    
                    var buttonColor: GetSberQRDataResponse.Parameter.Button.Color {
                        
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
                    
                    var placement: GetSberQRDataResponse.Parameter.Button.Placement {
                        
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
                
                var parameter: GetSberQRDataResponse.Parameter? {
                    
                    switch type {
                    case .amount:
                        guard let title,
                              let validationRules,
                              let amountButton = button?.amountButton
                        else { return nil }
                        
                        return .amount(.init(
                            id: id,
                            value: value,
                            title: title,
                            validationRules: validationRules.map(\.rule),
                            button: amountButton
                        ))
                        
                    case .button:
                        guard let value,
                              let color = color?.buttonColor,
                              let placement = placement?.placement,
                              let action = action?.action
                        else { return nil }
                        
                        return
                            .button(.init(
                                id: id,
                                value: value,
                                color: color,
                                action: action,
                                placement: placement
                            ))
                        
                    case .dataString:
                        guard let value else { return nil }
                        
                        return .dataString(.init(id: id, value: value))
                        
                    case .header:
                        return value.map {
                            
                            .header(.init(
                                id: id,
                                value: $0
                            ))
                        }
                        
                    case .productSelect:
                        guard let title,
                              let filter = filter?.filter
                        else { return nil }
                        
                        return .productSelect(.init(
                            id: id,
                            value: value,
                            title: title,
                            filter: filter
                        ))
                        
                    case .info:
                        guard let value,
                              let title,
                              let icon = icon?.icon
                        else { return nil }
                        
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
            
            var response: GetSberQRDataResponse {
                
                .init(
                    qrcID: qrcId,
                    parameters: parameters.compactMap(\.parameter),
                    required: required.map(\.required)
                )
            }
        }
    }
}

