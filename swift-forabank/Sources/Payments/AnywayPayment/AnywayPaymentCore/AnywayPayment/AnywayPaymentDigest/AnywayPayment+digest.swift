//
//  AnywayPayment+makeDigest.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentDomain
import Foundation

public extension AnywayPaymentContext {
    
    func makeDigest(
        locale: Locale = .autoupdatingCurrent,
        targetDecimalSymbol: Character = "."
    ) -> AnywayPaymentDigest {
        
        guard !shouldRestart
        else {
            // TODO: add tests
            return .init(
                additional: [], 
                amount: nil,
                core: nil,
                puref: outline.payload.puref
            )
        }
        
        let existingDecimalSymbol = locale.decimalSeparator?.first ?? targetDecimalSymbol
        let additional = payment.additional(
            replacingExistingDecimalSymbol: existingDecimalSymbol,
            withTargetDecimalSymbol: targetDecimalSymbol
        )
        
        return .init(
            additional: additional,
            amount: payment.amount,
            core: payment.core(),
            puref: outline.payload.puref
        )
    }
}

private extension AnywayPayment {
    
    func additional(
        replacingExistingDecimalSymbol existingDecimalSymbol: Character,
        withTargetDecimalSymbol targetDecimalSymbol: Character
    ) -> [AnywayPaymentDigest.Additional] {
        
        parameters.enumerated().compactMap { index, parameter in
            
            parameter.field.value.map { value in
                
                let value = {
                    if parameter.uiAttributes.dataType == .number {
                        return value.replacingOccurrences(of: String(existingDecimalSymbol), with: String(targetDecimalSymbol))
                    } else {
                        return value
                    }
                }()
                
                return .init(
                    fieldID: index, 
                    fieldName: parameter.field.id,
                    fieldValue: value
                )
            }
        }
    }
    
    func core() -> AnywayPaymentDigest.PaymentCore? {
        
        guard case let .widget(.product(core)) = elements.first(where: { $0.widget?.id == .product })
        else { return nil}
        
        return .init(
            currency: core.currency,
            productID: core.productID,
            productType: core._productType
        )
    }
    
    var parameters: [AnywayElement.Parameter] {
        
        elements.compactMap(\.parameter)
    }
}

private extension AnywayElement {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self else { return nil }
        
        return parameter
    }
    
    var widget: Widget? {
        
        guard case let .widget(widget) = self else { return nil }
        
        return widget
    }
}

private extension AnywayElement.Widget.Product {
    
    var _productType: AnywayPaymentDigest.PaymentCore.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}
