//
//  SberQRConfirmPaymentState.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation

public enum SberQRConfirmPaymentState: Equatable {
    
    case editableAmount(EditableAmount)
    case fixedAmount(FixedAmount)
}

public extension SberQRConfirmPaymentState {
    
    typealias Amount = GetSberQRDataResponse.Parameter.Amount
    typealias Button = GetSberQRDataResponse.Parameter.Button
    typealias DataString = GetSberQRDataResponse.Parameter.DataString
    typealias Header = GetSberQRDataResponse.Parameter.Header
    typealias Info = GetSberQRDataResponse.Parameter.Info
    
    struct EditableAmount: Equatable {
        
        public let header: Header
        public var productSelect: ProductSelect
        public let brandName: Info
        public let recipientBank: Info
        public let currency: DataString
        public var bottom: Amount
        
        public init(
            header: Header,
            productSelect: ProductSelect,
            brandName: Info,
            recipientBank: Info,
            currency: DataString,
            bottom: Amount
        ) {
            self.header = header
            self.productSelect = productSelect
            self.brandName = brandName
            self.recipientBank = recipientBank
            self.currency = currency
            self.bottom = bottom
        }
    }
    
    struct FixedAmount: Equatable {
        
        public let header: Header
        public var productSelect: ProductSelect
        public let brandName: Info
        public let amount: Info
        public let recipientBank: Info
        public let bottom: Button
        
        public init(
            header: Header,
            productSelect: ProductSelect,
            brandName: Info,
            amount: Info,
            recipientBank: Info,
            bottom: Button
        ) {
            self.header = header
            self.productSelect = productSelect
            self.brandName = brandName
            self.amount = amount
            self.recipientBank = recipientBank
            self.bottom = bottom
        }
    }
}

public extension SberQRConfirmPaymentState {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse
    ) throws {
        
        if response.required.contains(.paymentAmount) {
            
            self = try .editableAmount(.init(
                product: product,
                response: response
            ))
            
        } else {
            
            self = try .fixedAmount(.init(
                product: product,
                response: response
            ))
        }
    }
}

private extension SberQRConfirmPaymentState.EditableAmount {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse
    ) throws {
        
        try self.init(
            header: response.parameters.header(),
            productSelect: .compact(product),
            brandName: response.parameters.info(withID: .brandName),
            recipientBank: response.parameters.info(withID: .recipientBank),
            currency: response.parameters.dataString(withID: .currency),
            bottom: response.parameters.amount()
        )
    }
}

private extension SberQRConfirmPaymentState.FixedAmount {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse
    ) throws {
        
        try self.init(
            header: response.parameters.header(),
            productSelect: .compact(product),
            brandName: response.parameters.info(withID: .brandName),
            amount: response.parameters.info(withID: .amount),
            recipientBank: response.parameters.info(withID: .recipientBank),
            bottom: response.parameters.button()
        )
    }
}

private extension Array where Element == GetSberQRDataResponse.Parameter {
    
    func amount(
    ) throws -> GetSberQRDataResponse.Parameter.Amount {
        
        guard case let .amount(amount) = first(where: { $0.case == .amount })
        else { throw ParameterError(missing: .amount) }
        
        return amount
    }
    
    func button(
    ) throws -> GetSberQRDataResponse.Parameter.Button {
        
        guard case let .button(button) = first(where: { $0.case == .button })
        else { throw ParameterError(missing: .button) }
        
        return button
    }
    
    func dataString(
        withID id: GetSberQRDataResponse.Parameter.DataString.ID
    ) throws -> GetSberQRDataResponse.Parameter.DataString {
        
        guard case let .dataString(dataString) = first(where: { $0.case == .dataString && $0.id == .dataString(id) })
        else { throw ParameterError(missing: .dataString) }
        
        return dataString
    }
    
    func header(
    ) throws -> GetSberQRDataResponse.Parameter.Header {
        
        guard case let .header(header) = first(where: { $0.case == .header })
        else { throw ParameterError(missing: .header) }
        
        return header
    }
    
    func info(
    ) throws -> GetSberQRDataResponse.Parameter.Info {
        
        guard case let .info(info) = first(where: { $0.case == .info })
        else { throw ParameterError(missing: .info) }
        
        return info
    }
    
    func info(
        withID id: GetSberQRDataResponse.Parameter.Info.ID
    ) throws -> GetSberQRDataResponse.Parameter.Info {
        
        guard case let .info(info) = first(where: { $0.case == .info && $0.id == .info(id) })
        else { throw ParameterError(missing: .info) }
        
        return info
    }
    
    func productSelect(
    ) throws -> GetSberQRDataResponse.Parameter.ProductSelect {
        
        guard case let .productSelect(productSelect) = first(where: { $0.case == .productSelect })
        else { throw ParameterError(missing: .productSelect) }
        
        return productSelect
    }
    
    struct ParameterError: Error {
        
        let missing: GetSberQRDataResponse.Parameter.Case
    }
}

private extension GetSberQRDataResponse.Parameter {
    
    var id: ID {
        
        switch self {
        case let .amount(amount):
            return .amount(amount.id)
            
        case let .button(button):
            return .button(button.id)
            
        case let .dataString(dataString):
            return .dataString(dataString.id)
            
        case let .header(header):
            return .header(header.id)
            
        case let .info(info):
            return .info(info.id)
            
        case let .productSelect(productSelect):
            return .productSelect(productSelect.id)
        }
    }
    
    enum ID: Equatable {
        
        case amount(Amount.ID)
        case button(Button.ID)
        case dataString(DataString.ID)
        case header(Header.ID)
        case info(Info.ID)
        case productSelect(ProductSelect.ID)
    }
    
    var `case`: Case {
        
        switch self {
        case .amount:
            return .amount
            
        case .button:
            return .button
            
        case .dataString:
            return .dataString
            
        case .header:
            return .header
            
        case .info:
            return .info
            
        case .productSelect:
            return .productSelect
        }
    }
    
    enum Case {
        
        case amount
        case button
        case dataString
        case header
        case info
        case productSelect
    }
}
