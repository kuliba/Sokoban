//
//  ResponseMapper+mapCreateSberQRPaymentResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias CreateSberQRPaymentResult = Result<CreateSberQRPaymentResponse, CreateSberQRPaymentError>
    
    static func mapCreateSberQRPaymentResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> CreateSberQRPaymentResult {
        
        do {
            
            let response = try JSONDecoder().decode(_Response.self, from: data)
            
            switch (httpURLResponse.statusCode, response.errorMessage, response.data) {
            case let (200, .none, .some(data)):
                return try .success(data.response())
                
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

private extension ResponseMapper {
    
    struct _Response: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: _Data?
        
        struct _Data: Decodable {
            
            let parameters: [Parameter]
            
            struct Parameter: Decodable {
                
                let id: ID
                let type: ParameterType
                let value: Value
                let style: Style?
                let color: Color?
                let action: Action?
                let icon: String?
                let subscriptionPurpose: SubscriptionPurpose?
                let placement: Placement?
            }
        }
    }
}

private extension ResponseMapper._Response._Data {
    
    func response() throws -> CreateSberQRPaymentResponse {
        
        try .init(parameters: parameters.map { try $0.parameter() })
    }
}

private extension ResponseMapper._Response._Data.Parameter {
    
    enum Action: String, Decodable {
        
        case main = "MAIN"
        
        var action: CreateSberQRPaymentResponse.Parameter.Action {
            
            switch self {
            case .main: return .main
            }
        }
    }
    
    enum Color: String, Decodable {
        
        case red
        
        var color: CreateSberQRPaymentResponse.Parameter.Color {
            
            switch self {
            case .red: return .red
            }
        }
    }
    
    enum ID: String, Decodable {
        
        case brandName = "brandName"
        case buttonMain = "button_main"
        case paymentOperationDetailId = "paymentOperationDetailId"
        case printFormType = "printFormType"
        case successStatus = "success_status"
        case successTitle = "success_title"
        case successAmount = "success_amount"
        case successOptionButtons = "success_option_buttons"
        
        var id: CreateSberQRPaymentResponse.Parameter.ID {
            
            switch self {
            case .brandName:
                return .brandName
            case .buttonMain:
                return .buttonMain
            case .paymentOperationDetailId:
                return .paymentOperationDetailId
            case .printFormType:
                return .printFormType
            case .successStatus:
                return .successStatus
            case .successTitle:
                return .successTitle
            case .successAmount:
                return .successAmount
            case .successOptionButtons:
                return .successOptionButtons
            }
        }
    }
    
    enum ParameterType: String, Decodable {
        
        case dataLong =            "DATA_LONG"
        case dataString =          "DATA_STRING"
        case successStatusIcon =   "SUCCESS_STATUS_ICON"
        case successText =         "SUCCESS_TEXT"
        case subscriber =           "SUBSCRIBER"
        case successOptionButton = "SUCCESS_OPTION_BUTTONS"
        case button =              "BUTTON"
    }
    
    enum Placement: String, Decodable {
        
        case bottom = "BOTTOM"
        
        var placement: CreateSberQRPaymentResponse.Parameter.Placement {
            
            switch self {
            case .bottom: return .bottom
            }
        }
    }
    
    enum Style: String, Decodable {
        
        case amount = "AMOUNT"
        case title = "TITLE"
        case small = "SMALL"
        
        var style: CreateSberQRPaymentResponse.Parameter.Style {
            
            switch self {
            case .amount: return .amount
            case .title:  return .title
            case .small:  return .small
            }
        }
    }
    
    struct SubscriptionPurpose: Decodable {
        
        var purpose: CreateSberQRPaymentResponse.Parameter.Subscriber.SubscriptionPurpose {
            
            .init()
        }
    }
    
    enum SuccessStatusIcon: String, Decodable {
        
        case complete = "COMPLETE"
        
        var icon: CreateSberQRPaymentResponse.Parameter.SuccessStatusIcon.StatusIcon {
            
            switch self {
            case .complete: return .complete
            }
        }
    }
    
    enum Value: Decodable {
        
        case int(Int)
        case options([Option])
        case string(String)
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            
            if let int = try? container.decode(Int.self) {
                self = .int(int)
                return
            }
            if let options = try? container.decode([Option].self) {
                self = .options(options)
                return
            }
            if let string = try? container.decode(String.self) {
                self = .string(string)
                return
            }
            
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is not a recognized type"))
        }
        
        enum Option: String, Decodable {
            
            case details = "DETAILS"
            case document = "DOCUMENT"
            
            var value: CreateSberQRPaymentResponse.Parameter.SuccessOptionButton.Value {
                
                switch self {
                case .details:  return .details
                case .document: return .document
                }
            }
        }
    }
    
    struct MappingError: Error {}
    
    func parameter() throws -> CreateSberQRPaymentResponse.Parameter {
        
        switch type {
        case .button:
            guard
                case let .string(value) = value,
                let color = color?.color,
                let action = action?.action,
                let placement
            else { throw MappingError() }
            
            return .button(.init(
                id: id.id,
                value: value,
                color: color,
                action: action,
                placement: placement.placement
            ))
            
        case .dataLong:
            guard case let .int(value) = value
            else { throw MappingError() }
            
            return .dataLong(.init(
                id: id.id,
                value: value
            ))
            
        case .dataString:
            guard case let .string(value) = value
            else { throw MappingError() }
            
            return .dataString(.init(
                id: id.id,
                value: value
            ))
            
        case .successStatusIcon:
            guard case let .string(string) = value,
                  let successStatusIcon = SuccessStatusIcon(rawValue: string)
            else { throw MappingError() }
            
            return .successStatusIcon(.init(
                id: id.id,
                value: successStatusIcon.icon
            ))
            
        case .successText:
            guard
                case let .string(value) = value,
                let style = style?.style
            else { throw MappingError() }
            
            return .successText(.init(
                id: id.id,
                value: value,
                style: style
            ))
            
        case .subscriber:
            guard
                case let .string(value) = value,
                let style = style?.style,
                let icon
            else { throw MappingError() }
            
            return .subscriber(.init(
                id: id.id,
                value: value,
                style: style,
                icon: icon,
                subscriptionPurpose: subscriptionPurpose?.purpose
            ))
            
        case .successOptionButton:
            guard case let .options(values) = value
            else { throw MappingError() }
            
            return .successOptionButton(.init(
                id: id.id,
                values: values.map(\.value)
            ))
        }
    }
}
