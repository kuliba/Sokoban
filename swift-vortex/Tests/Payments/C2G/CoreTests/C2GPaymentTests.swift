//
//  C2GPaymentTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GCore
import PaymentComponents
import SwiftUI
import UIPrimitives
import XCTest

class C2GPaymentTests: XCTestCase {
    
    typealias State = C2GPaymentState
    
    func makeState(
        productSelect: ProductSelect? = nil,
        termsCheck: Bool = false,
        uin: String = anyMessage(),
        url: URL = anyURL()
    ) -> State {
        
        return .init(
            productSelect: productSelect ?? makeProductSelect(),
            termsCheck: termsCheck,
            uin: uin,
            url: url
        )
    }
    
    func makeProductSelect(
        selected: ProductSelect.Product? = nil,
        products: ProductSelect.Products? = nil
    ) -> ProductSelect {
        
        return .init(
            selected: selected,
            products: products
        )
    }
    
    func makeProduct(
        id: Int = .random(in: 1...100),
        type: ProductSelect.Product.ProductType = .account,
        isAdditional: Bool = false,
        header: String = anyMessage(),
        title: String = anyMessage(),
        footer: String = anyMessage(),
        amountFormatted: String = anyMessage(),
        balance: Decimal = 123,
        look: ProductSelect.Product.Look? = nil
    ) -> ProductSelect.Product {
        
        return .init(
            id: .init(id),
            type: type,
            isAdditional: isAdditional,
            header: header,
            title: title,
            footer: footer,
            amountFormatted: amountFormatted,
            balance: balance,
            look: look ?? makeLook()
        )
    }
    
    func makeLook(
        background: Icon = .image(.init(systemName: "plane")),
        color: Color = .blue,
        icon: Icon = .image(.init(systemName: "plane"))
    ) -> ProductSelect.Product.Look {
        
        return .init(
            background: background,
            color: color,
            icon: icon
        )
    }
}
