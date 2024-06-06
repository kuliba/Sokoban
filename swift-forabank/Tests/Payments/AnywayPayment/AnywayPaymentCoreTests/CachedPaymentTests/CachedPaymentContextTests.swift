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
        
        let context = makeContext(staged: [])
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(staged: [.init("1"), .init("2")])
        )
        
        XCTAssertNoDiff(updated.staged, [.init("1"), .init("2")])
    }
    
    func test_updating_shouldUpdateNonEmptyStaged() {
        
        let context = makeContext(staged: [.init("0")])
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(staged: [.init("1"), .init("2")])
        )
        
        XCTAssertNoDiff(updated.staged, [.init("1"), .init("2")])
    }
    
    func test_updating_shouldUpdateOutline() {
        
        let context = makeContext(outline: .init(
            core: makeOutlinePaymentCore(
                amount: 123,
                currency: "RUB",
                productID: 321,
                productType: .account
            ),
            fields: ["321": "abc"]
        ))
        
        let outline = makeAnywayPaymentOutline(
            ["a": "aaa"],
            core: makeOutlinePaymentCore(
                amount: 321,
                currency: "USD",
                productID: 987,
                productType: .card
            )
        )
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(outline: outline)
        )
        
        XCTAssertNoDiff(updated.outline, outline)
    }
    
    func test_updating_shouldUpdateShouldRestart_false() {
        
        let context = makeContext(shouldRestart: true)
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(shouldRestart: false)
        )
        
        XCTAssertFalse(updated.shouldRestart)
    }
    
    func test_updating_shouldUpdateShouldRestart_true() {
        
        let context = makeContext(shouldRestart: false)
        
        let updated = updating(
            context,
            with: makeAnywayPaymentContext(shouldRestart: true)
        )
        
        XCTAssertTrue(updated.shouldRestart)
    }
    
    // MARK: - Helpers
    
    private func updating(
        _ context: CachedContext,
        with anywayContext: AnywayPaymentContext
    ) -> CachedContext {
        
        context.updating(with: anywayContext, using: { $0 })
    }
}

private typealias CachedContext = CachedPaymentContext<AnywayPayment.Element>
private typealias CachedPayment = CachedAnywayPayment<AnywayPayment.Element>

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

private func makeAnywayPaymentContext(
    payment: AnywayPayment = makeAnywayPayment(),
    staged: AnywayPaymentStaged = [],
    outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
    shouldRestart: Bool = false
) -> AnywayPaymentContext {
    
    return .init(
        payment: payment,
        staged: staged,
        outline: outline,
        shouldRestart: shouldRestart
    )
}
