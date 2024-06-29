//
//  AnywayPaymentOutline+updating.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentOutline {
    
    public func updating(with payment: AnywayPayment) -> Self {
        
        let fields = fields.merging(
            payment.elements.compactMap(\.idValuePair),
            uniquingKeysWith: { _, new in new }
        )
        
        return .init(
            amount: payment.amount ?? 0,
            product: payment.product ?? product,
            fields: fields,
            payload: payload
        )
    }
}

private extension AnywayPayment {
    
    var product: AnywayPaymentOutline.Product? {
        
        guard case let .widget(.product(product)) = elements[id: .widgetID(.product)]
        else { return nil }
        
        return .init(product)
    }
}

private extension AnywayPaymentOutline.Product {
    
    init(_ product: AnywayElement.Widget.Product) {
        
        self.init(
            currency: product.currency,
            productID: product.productID,
            productType: .init(product.productType)
        )
    }
}

private extension AnywayPaymentOutline.Product.ProductType {
    
    init(_ type: AnywayElement.Widget.Product.ProductType) {
        
        switch type {
        case .account: self = .account
        case .card:    self = .card
        }
    }
}

private extension AnywayElement {
    
    var idValuePair: (AnywayPaymentOutline.ID, AnywayPaymentOutline.Value)? {
        
        guard case let .parameter(parameter) = self,
              parameter.isOutlinable
        else { return nil }
        
        return parameter.field.value.map {
            
            (parameter.field.id, $0)
        }
    }
}

private extension AnywayElement.Parameter {
    
    var isOutlinable: Bool {
        
        uiAttributes.viewType == .input
    }
}
