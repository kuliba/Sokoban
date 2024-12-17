//
//  ResponseMapper+mapCreateSberQRPaymentResponse.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias CreateSberQRPaymentResult = Result<CreateSberQRPaymentResponse, MappingError>
    
    static func mapCreateSberQRPaymentResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> CreateSberQRPaymentResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CreateSberQRPaymentResponse {
        
        try .init(parameters: data.parameters.map { try $0.parameter() })
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let parameters: [Parameter]
    }
}

private extension ResponseMapper._Data {
    
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

private extension ResponseMapper._Data.Parameter {
    
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
        
        var color: Parameters.Color {
            
            switch self {
            case .red: return .red
            }
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            let stringValue = try container.decode(String.self)
            
            switch stringValue.lowercased() {
            case "red":
                self = .red
                
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid color value")
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
        
        var buttonID: CreateSberQRPaymentIDs.ButtonID? {
            
            switch self {
            case .buttonMain: return .buttonMain
            default:          return nil
            }
        }
        
        var dataLongID: CreateSberQRPaymentIDs.DataLongID? {
            
            switch self {
            case .paymentOperationDetailId: 
                return .paymentOperationDetailId
            default:
                return nil
            }
        }
        
        var dataStringID: CreateSberQRPaymentIDs.DataStringID? {
            
            switch self {
            case .printFormType: return .printFormType
            default:             return nil
            }
        }
        
        var subscriberID: CreateSberQRPaymentIDs.SubscriberID? {
            
            switch self {
            case .brandName: return .brandName
            default:         return nil
            }
        }
        
        var successOptionButtonsID: CreateSberQRPaymentIDs.SuccessOptionButtonsID? {
            
            switch self {
            case .successOptionButtons:
                return .successOptionButtons
            default:
                return nil
            }
        }
        
        var successStatusID: CreateSberQRPaymentIDs.SuccessStatusID? {
            
            switch self {
            case .successStatus: return .successStatus
            default:             return nil
            }
        }
        
        var successTextID: CreateSberQRPaymentIDs.SuccessTextID? {
            
            switch self {
            case .successAmount: return .successAmount
            case .successTitle:  return .successTitle
            default:             return nil
            }
        }
    }
    
    enum ParameterType: String, Decodable {
        
        case dataLong =            "DATA_LONG"
        case dataString =          "DATA_STRING"
        case successStatusIcon =   "SUCCESS_STATUS_ICON"
        case successText =         "SUCCESS_TEXT"
        case subscriber =          "SUBSCRIBER"
        case successOptionButton = "SUCCESS_OPTION_BUTTONS"
        case button =              "BUTTON"
    }
    
    enum Placement: String, Decodable {
        
        case bottom = "BOTTOM"
        
        var placement: Parameters.Placement {
            
            switch self {
            case .bottom: return .bottom
            }
        }
    }
    
    enum Style: String, Decodable {
        
        case amount = "AMOUNT"
        case title =  "TITLE"
        case small =  "SMALL"
        
        var style: Parameters.Style {
            
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
        case inProgress = "IN_PROGRESS"
        case rejected = "REJECTED"
        case suspended = "SUSPEND"
        
        var icon: CreateSberQRPaymentResponse.Parameter.SuccessStatusIcon.StatusIcon {
            
            switch self {
            case .complete: return .complete
            case .inProgress: return .inProgress
            case .rejected: return .rejected
            case .suspended: return .suspended
            }
        }
    }
    
    enum Value: Decodable {
        
        case options([Option])
        case string(String)
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            
            if let int = try? container.decode(Int.self) {
                self = .string("\(int)")
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
            
            var value: CreateSberQRPaymentResponse.Parameter.SuccessOptionButtons.Value {
                
                switch self {
                case .details:  return .details
                case .document: return .document
                }
            }
        }
    }
}

private extension ResponseMapper._Data.Parameter {
    
    struct MappingError: Error {}
    
    func parameter() throws -> CreateSberQRPaymentResponse.Parameter {
        
        switch type {
        case .button:
            guard
                let id = id.buttonID,
                case let .string(value) = value,
                let color = color?.color,
                let action = action?.action,
                let placement
            else { throw MappingError() }
            
            return .button(.init(
                id: id,
                value: value,
                color: color,
                action: action,
                placement: placement.placement
            ))
            
        case .dataLong:
            guard
                let id = id.dataLongID,
                case let .string(value) = value,
                let value = Int(value)
            else { throw MappingError() }
            
            return .dataLong(.init(
                id: id,
                value: value
            ))
            
        case .dataString:
            guard
                let id = id.dataStringID,
                case let .string(value) = value
            else { throw MappingError() }
            
            return .dataString(.init(
                id: id,
                value: value
            ))
            
        case .successStatusIcon:
            guard
                let id = id.successStatusID,
                case let .string(string) = value,
                  let successStatusIcon = SuccessStatusIcon(rawValue: string)
            else { throw MappingError() }
            
            return .successStatusIcon(.init(
                id: id,
                value: successStatusIcon.icon
            ))
            
        case .successText:
            guard
                let id = id.successTextID,
                case let .string(value) = value,
                let style = style?.style
            else { throw MappingError() }
            
            return .successText(.init(
                id: id,
                value: value,
                style: style
            ))
            
        case .subscriber:
            guard
                let id = id.subscriberID,
                case let .string(value) = value,
                let style = style?.style,
                let icon
            else { throw MappingError() }
            
            return .subscriber(.init(
                id: id,
                value: value,
                style: style,
                icon: icon,
                subscriptionPurpose: subscriptionPurpose?.purpose
            ))
            
        case .successOptionButton:
            guard
                let id = id.successOptionButtonsID,
                case let .options(values) = value
            else { throw MappingError() }
            
            return .successOptionButton(.init(
                id: id,
                values: values.map(\.value)
            ))
        }
    }
}
