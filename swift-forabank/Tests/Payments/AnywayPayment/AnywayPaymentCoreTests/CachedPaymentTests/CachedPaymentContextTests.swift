//
//  CachedPaymentContextTests.swift
//
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class CachedPaymentContextTests: XCTestCase {
    
    func test_init_shouldCreateInstanceWithPurefFromAnywayPaymentWithPuref() {
        
        let puref = anyMessage()
        let context = makeAnywayPaymentContext(
            outline: makeAnywayPaymentOutline(
                payload: makeAnywayPaymentPayload(puref: puref)
            )
        )
        
        let cached = CachedPaymentContext(context, using: { $0 })
        
        XCTAssertNoDiff(cached.outline.payload.puref, puref)
    }
    
    // MARK: - updating
    
    func test_updating_shouldUpdatePayment() {
        
        let context = makeContext(payment: makeCachedPayment())
        
        let field = makeAnywayPaymentField(id: "123")
        let newPayment = makeAnywayPayment(elements: [.field(field)])
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(payment: newPayment)
        )
        let updatedPayment = context.payment.updating(with: newPayment, using: { $0 })
        
        XCTAssertNoDiff(updated.payment, updatedPayment)
    }
    
    func test_updating_shouldUpdateEmptyStaged() {
        
        let updated = updating(
            makeContext(staged: []),
            with: makeAnywayPaymentContext(staged: [.init("1"), .init("2")])
        )
        
        XCTAssertNoDiff(updated.staged, [.init("1"), .init("2")])
    }
    
    func test_updating_shouldUpdateNonEmptyStaged() {
        
        let updated = updating(
            makeContext(staged: [.init("0")]),
            with: makeAnywayPaymentContext(staged: [.init("1"), .init("2")])
        )
        
        XCTAssertNoDiff(updated.staged, [.init("1"), .init("2")])
    }
    
    func test_updating_shouldUpdateOutline() {
        
        let outline = makeAnywayPaymentOutline(
            ["321": "abc"],
            core: makeOutlinePaymentCore(
                amount: 123,
                currency: "RUB",
                productID: 321,
                productType: .account
            )
        )
        
        let newOutline = makeAnywayPaymentOutline(
            ["a": "aaa"],
            core: makeOutlinePaymentCore(
                amount: 321,
                currency: "USD",
                productID: 987,
                productType: .card
            )
        )
        
        let updated = updating(
            makeContext(outline: outline),
            with: makeAnywayPaymentContext(outline: newOutline)
        )
        
        XCTAssertNoDiff(updated.outline, newOutline)
    }
    
    func test_updating_shouldUpdateShouldRestart_false() {
        
        let updated = updating(
            makeContext(shouldRestart: true),
            with: makeAnywayPaymentContext(shouldRestart: false)
        )
        
        XCTAssertFalse(updated.shouldRestart)
    }
    
    func test_updating_shouldUpdateShouldRestart_true() {
        
        let updated = updating(
            makeContext(shouldRestart: false),
            with: makeAnywayPaymentContext(shouldRestart: true)
        )
        
        XCTAssertTrue(updated.shouldRestart)
    }
    
    func test_updating_shouldUpdateWithPurefFromAnywayPaymentContextWithPuref() {
        
        let puref1 = anyMessage()
        let context = makeContext(
            outline: makeAnywayPaymentOutline(
                payload: makeAnywayPaymentPayload(puref: puref1)
            )
        )
        XCTAssertNoDiff(context.outline.payload.puref, puref1)
        
        let puref2 = anyMessage()
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(
                outline: makeAnywayPaymentOutline(
                    payload: makeAnywayPaymentPayload(puref: puref2)
                )
            )
        )
        
        XCTAssertNoDiff(updated.outline.payload.puref, puref2)
    }
    
    // MARK: - Helpers
    
    private func updating(
        _ context: CachedContext,
        with anywayContext: AnywayPaymentContext
    ) -> CachedContext {
        
        context.updating(with: anywayContext, using: { $0 })
    }
}

private typealias CachedContext = CachedPaymentContext<AnywayElement>
private typealias CachedPayment = CachedAnywayPayment<AnywayElement>

private func makeContext(
    payment: CachedPayment = makeCachedPayment(),
    staged: AnywayPaymentStaged = [],
    outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
    shouldRestart: Bool = false
) -> CachedContext {
    
    return .init(
        payment: payment,
        staged: staged,
        outline: outline,
        shouldRestart: shouldRestart
    )
}

private func makeCachedPayment(
    payment: AnywayPayment = makeAnywayPayment()
) -> CachedPayment {
    
    return .init(payment, using: { $0 })
}
