//
//  SberQRConfirmPaymentState+init.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

import PaymentComponents

public extension SberQRConfirmPaymentState {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse,
        isInflight: Bool = false
    ) throws {
        
        if response.required.contains(.paymentAmount) {
            
            try self.init(
                confirm: .editableAmount(.init(
                    product: product,
                    response: response
                )),
                isInflight: isInflight
            )
            
        } else {
            
            self = try .init(
                confirm: .fixedAmount(.init(
                    product: product,
                    response: response
                )
                ),
                isInflight: isInflight
            )
        }
    }
}

private extension EditableAmount<GetSberQRDataResponse.Parameter.Info> {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse
    ) throws {
        
        try self.init(
            header: response.parameters.header(),
            productSelect: .init(selected: product),
            brandName: response.parameters.info(withID: .brandName),
            recipientBank: response.parameters.info(withID: .recipientBank),
            currency: response.parameters.dataString(withID: .currency),
            amount: response.parameters.amount()
        )
    }
}

private extension FixedAmount<GetSberQRDataResponse.Parameter.Info> {
    
    init(
        product: ProductSelect.Product,
        response: GetSberQRDataResponse
    ) throws {
        
        try self.init(
            header: response.parameters.header(),
            productSelect: .init(selected: product),
            brandName: response.parameters.info(withID: .brandName),
            amount: response.parameters.info(withID: .amount),
            recipientBank: response.parameters.info(withID: .recipientBank),
            button: response.parameters.button()
        )
    }
}

private extension Array where Element == GetSberQRDataResponse.Parameter {
    
    func amount(
    ) throws -> Amount {
        
        guard case let .amount(amount) = first(where: { $0.case == .amount })
        else { throw ParameterError(missing: .amount) }
        
#warning("isEnabled also depends product balance")
        
        return .init(
            title: amount.title,
            value: amount.value,
            button: .init(
                title: amount.button.title,
                // TODO: add product balance as a cap
                isEnabled: 0 < amount.value
            )
        )
    }
    
    func button(
    ) throws -> ButtonComponent.Button {
        
        guard case let .button(button) = first(where: { $0.case == .button })
        else { throw ParameterError(missing: .button) }
        
        return .init(button)
    }
    
    func dataString(
        withID id: GetSberQRDataIDs.DataStringID
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
        withID id: GetSberQRDataIDs.InfoID
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
        
        case amount(GetSberQRDataIDs.AmountID)
        case button(GetSberQRDataIDs.ButtonID)
        case dataString(GetSberQRDataIDs.DataStringID)
        case header(GetSberQRDataIDs.HeaderID)
        case info(GetSberQRDataIDs.InfoID)
        case productSelect(GetSberQRDataIDs.ProductSelectID)
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

// MARK: - Mapping

private extension ButtonComponent.Button {
    
    init(_ button: GetSberQRDataResponse.Parameter.Button) {
        
        self.init(
            id: .init(button.id),
            value: button.value,
            color: .init(button.color),
            action: .init(button.action),
            placement: .init(button.placement)
        )
    }
}

private extension ButtonComponent.Button.Action {
    
    init(_ action: GetSberQRDataResponse.Parameter.Action) {
        
        switch action {
        case .pay: self = .pay
        }
    }
}

private extension ButtonComponent.Button.Color {
    
    init(_ color: Parameters.Color) {
        
        switch color {
        case .red: self = .red
        }
    }
}

private extension ButtonComponent.Button.ID {
    
    init(_ id: GetSberQRDataIDs.ButtonID) {
        
        switch id {
        case .buttonPay: self = .buttonPay
        }
    }
}

private extension ButtonComponent.Button.Placement {
    
    init(_ placement: Parameters.Placement) {
        
        switch placement {
        case .bottom: self = .bottom
        }
    }
}
