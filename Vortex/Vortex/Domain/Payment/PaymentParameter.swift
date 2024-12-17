//
//  QRScenarioParameter.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

protocol PaymentParameterProtocol<Value>: Identifiable, Equatable, Decodable where Value: Decodable {
    
    associatedtype Value
    
    var id: String { get }
    var value: Value { get }
}

enum PaymentParameterType: String, Decodable, Unknownable {
    
    case header = "HEADER"
    case subscriber = "SUBSCRIBER"
    case productSelect = "PRODUCT_SELECT"
    case check = "CHECK"
    case button = "BUTTON"
    case icon = "ICON"
    case info = "INFO"
    case status = "SUCCESS_STATUS_ICON"
    case text = "SUCCESS_TEXT"
    case optionButtons = "SUCCESS_OPTION_BUTTONS"
    case amount = "AMOUNT"
    case link = "SUCCESS_LINK"
    case dataInt = "DATA_LONG"
    case dataString = "DATA_STRING"
    case unknown
}

enum PaymentParameterIconType: String, Decodable {
    
    case remote = "REMOTE"
    case local = "LOCAL"
}

//MARK: - Parameters

struct PaymentParameterHeader: PaymentParameterProtocol {
    
    let id: String
    let value: String
}

struct PaymentParameterSubscriber: PaymentParameterProtocol {

    let id: String
    let value: String
    let icon: String
    let legalName: String?
    let subscriptionPurpose: String?
    let style: Payments.ParameterSubscriber.Style
}

struct PaymentParameterProductSelect: PaymentParameterProtocol {

    let id: String
    let value: String?
    let title: String
    let filter: Filter
    
    struct Filter: Equatable, Decodable  {
        
        let productTypes: [ProductType]
        let currencies: [Currency]
        let additional: Bool
    }
}

struct PaymentParameterCheck: PaymentParameterProtocol {

    let id: String
    let value: Bool
    let link: Link
    
    struct Link: Equatable, Decodable {
        
        //FIXME: - extract title to root
        let title: String
        let subtitle: String
        let url: URL
    }
}

struct PaymentParameterButton: PaymentParameterProtocol {
    
    let id: String
    let value: String
    let color: Payments.ParameterButton.Style
    let action: Payments.ParameterButton.Action
    let placement: Payments.Parameter.Placement
}

struct PaymentParameterIcon: PaymentParameterProtocol {
    
    let id: String
    let value: String
    let iconType: PaymentParameterIconType
    let placement: Payments.Parameter.Placement
}

struct PaymentParameterInfo: PaymentParameterProtocol {
    
    let id: String
    let value: String?
    let title: String
    let icon: Icon
    
    struct Icon: Decodable, Equatable {
        
        let type: PaymentParameterIconType
        let value: String
        
        var parameterIcon: Payments.Parameter.Icon {
            
            switch type {
            case .local: return .local(value)
            case .remote: return .remote(value)
            }
        }
    }
}

struct PaymentParameterStatus: PaymentParameterProtocol {
    
    let id: String
    let value: TransferResponseBaseData.DocumentStatus
}

struct PaymentParameterText: PaymentParameterProtocol {
    
    let id: String
    let value: String
    let style: Payments.ParameterSuccessText.Style
}

struct PaymentParameterOptionButtons: PaymentParameterProtocol {
    
    let id: String
    let value: [Payments.ParameterSuccessOptionButtons.Option]
}

struct PaymentParameterAmount: PaymentParameterProtocol {
    
    let id: String
    let value: Decimal?
    let title: String
    
    //TODO: implement other properties
}

struct PaymentParameterLink: PaymentParameterProtocol {
    
    let id: String
    let value: URL
    let title: String
}

struct PaymentParameterDataInt: PaymentParameterProtocol {
    
    let id: String
    let value: Int
}

struct PaymentParameterDataString: PaymentParameterProtocol {
    
    let id: String
    let value: String
}

struct PaymentParameterTypeData: Decodable {
    
    let type: PaymentParameterType
}
    
//MARK: - Boxing

struct AnyPaymentParameter: Equatable {

    let id: String
    let parameter: Any
    
    init<P>(_ parameter: P) where P : PaymentParameterProtocol {
        
        self.id = parameter.id
        self.parameter = parameter
    }
    
    static func == (lhs: AnyPaymentParameter, rhs: AnyPaymentParameter) -> Bool {
        
        switch (lhs.parameter, rhs.parameter) {
        case (let lhsParam as PaymentParameterHeader, let rhsParam as PaymentParameterHeader):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterSubscriber, let rhsParam as PaymentParameterSubscriber):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterProductSelect, let rhsParam as PaymentParameterProductSelect):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterCheck, let rhsParam as PaymentParameterCheck):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterButton, let rhsParam as PaymentParameterButton):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterIcon, let rhsParam as PaymentParameterIcon):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterInfo, let rhsParam as PaymentParameterInfo):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterStatus, let rhsParam as PaymentParameterStatus):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterText, let rhsParam as PaymentParameterText):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterOptionButtons, let rhsParam as PaymentParameterOptionButtons):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterAmount, let rhsParam as PaymentParameterAmount):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterLink, let rhsParam as PaymentParameterLink):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterDataInt, let rhsParam as PaymentParameterDataInt):
            return lhsParam == rhsParam
            
        case (let lhsParam as PaymentParameterDataString, let rhsParam as PaymentParameterDataString):
            return lhsParam == rhsParam

        default:
            return false
        }
    }
}

//MARK: - Decoding

extension AnyPaymentParameter {
    
    static func decode(container: UnkeyedDecodingContainer) throws -> [AnyPaymentParameter] {
        
        var typesContainer = container
        var valuesContainer = container
        
        var parameters = [AnyPaymentParameter]()
        
        while typesContainer.isAtEnd == false {
            
            let type = try typesContainer.decode(PaymentParameterTypeData.self).type
            
            switch type {
            case .header:
                parameters.append(.init(try valuesContainer.decode(PaymentParameterHeader.self)))
                
            case .subscriber:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterSubscriber.self)))
                
            case .productSelect:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterProductSelect.self)))
                
            case .check:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterCheck.self)))
            
            case .button:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterButton.self)))
                
            case .icon:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterIcon.self)))
                
            case .info:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterInfo.self)))
                
            case .status:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterStatus.self)))
                
            case .text:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterText.self)))
                
            case .optionButtons:
                parameters.append(.init( try valuesContainer.decode(PaymentParameterOptionButtons.self)))
                
            case .amount:
                parameters.append(.init(try valuesContainer.decode(PaymentParameterAmount.self)))
                
            case .link:
                parameters.append(.init(try valuesContainer.decode(PaymentParameterLink.self)))
                
            case .dataInt:
                parameters.append(.init(try valuesContainer.decode(PaymentParameterDataInt.self)))
                
            case .dataString:
                parameters.append(.init(try valuesContainer.decode(PaymentParameterDataString.self)))
                
            case .unknown:
                let _ = try valuesContainer.decode(PaymentParameterTypeData.self)
            }
        }
        
        return parameters
    }
}
