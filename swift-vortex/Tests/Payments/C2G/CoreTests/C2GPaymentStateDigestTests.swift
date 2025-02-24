//
//  C2GPaymentStateDigestTests.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import XCTest

final class C2GPaymentStateDigestTests: C2GPaymentTests {
    
    func test_shouldDeliverNil_onTermsCheckFalse() {
        
        let product = makeProduct()
        let state = makeState(
            productSelect: makeProductSelect(
                selected: product,
                products: [product]
            ),
            termsCheck: false
        )
        
        XCTAssertNil(state.digest)
    }
    
    func test_shouldDeliverNil_onUnselectedProduct() {
        
        let state = makeState(
            productSelect: makeProductSelect(
                selected: nil,
                products: [makeProduct()]
            ),
            termsCheck: false
        )
        
        XCTAssertNil(state.digest)
    }
    
    func test_shouldDeliverAccountDigest() {
        
        let id: Int = .random(in: 1...100)
        let product = makeProduct(id: id, type: .account)
        let uin = anyMessage()
        let state = makeState(
            productSelect: makeProductSelect(
                selected: product,
                products: [product]
            ),
            termsCheck: true,
            uin: uin
        )
        
        XCTAssertNoDiff(state.digest, .init(product: product, uin: uin))
    }
    
    func test_shouldDeliverCardDigest() {
        
        let id: Int = .random(in: 1...100)
        let product = makeProduct(id: id, type: .card)
        let uin = anyMessage()
        let state = makeState(
            productSelect: makeProductSelect(
                selected: product,
                products: [product]
            ),
            termsCheck: true,
            uin: uin
        )
        
        XCTAssertNoDiff(state.digest, .init(product: product, uin: uin))
    }
}
