//
//  AnywayPaymentMakeDigestTests.swift
//
//
//  Created by Igor Malyarov on 10.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentMakeDigestTests: XCTestCase {
    
    func test_shouldSetAdditionalToEmptyOnEmptyElements() {
        
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(elements: [])
        )
        
        XCTAssert(context.makeDigest().additional.isEmpty)
    }
    
    func test_shouldSetAdditionalToEmptyOnEmptyParameters() {
        
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(fields: [makeAnywayPaymentField()])
        )
        
        XCTAssert(context.makeDigest().additional.isEmpty)
    }
    
    func test_shouldNotSetAdditionalOnParameterWithNilValue() {
        
        let parameter = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(value: nil)
        )
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(parameters: [parameter])
        )
        
        XCTAssert(context.makeDigest().additional.isEmpty)
    }
    
    func test_shouldSetAdditionalOnParameter() {
        
        let (id, value) = (anyMessage(), anyMessage())
        let parameter = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
                id: id, value: value
            )
        )
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(parameters: [parameter])
        )
        
        XCTAssertNoDiff(context.makeDigest().additional, [
            .init(fieldID: 0, fieldName: id, fieldValue: value),
        ])
    }
    
    func test_shouldSetAdditionalOnNonEmptyParameters() {
        
        let (id0, value0) = (anyMessage(), anyMessage())
        let (id1, value1) = (anyMessage(), anyMessage())
        let parameter1 = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
                id: id0, value: value0
            )
        )
        let parameter2 = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
                id: id1, value: value1
            )
        )
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(parameters: [parameter1, parameter2])
        )
        
        XCTAssertNoDiff(context.makeDigest().additional, [
            .init(fieldID: 0, fieldName: id0, fieldValue: value0),
            .init(fieldID: 1, fieldName: id1, fieldValue: value1),
        ])
    }
    
    func test_shouldSetCoreToNilOnPaymentWithoutAmount() {
        
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPaymentWithoutAmount()
        )
        
        XCTAssertNil(context.makeDigest().core)
    }
    
    func test_shouldSetCoreAmountOnPaymentWithAmount() {
        
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPaymentWithAmount(12_345.67)
        )
        
        XCTAssertNoDiff(context.makeDigest().amount, 12_345.67)
    }
    
    func test_shouldSetCoreWithAccountIDOnPaymentWithProduct() {
        
        let (_, currency, id) = makeCore()
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPaymentWithProduct(currency, id, .account)
        )
        
        XCTAssertNoDiff(context.makeDigest().core, .init(
            currency: currency,
            productID: id,
            productType: .account
        ))
    }
    
    func test_shouldSetCoreWithCardIDOnPaymentWithProduct() {
        
        let (_, currency, id) = makeCore()
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPaymentWithProduct(currency, id, .card)
        )
        
        XCTAssertNoDiff(context.makeDigest().core, .init(
            currency: .init(currency),
            productID: id,
            productType: .card
        ))
    }
    
    func test_shouldSetPuref() {
        
        let puref = anyMessage()
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(),
            outline: makeAnywayPaymentOutline(
                payload: makeAnywayPaymentPayload(puref: puref)
            )
        )
        
        XCTAssertNoDiff(context.makeDigest().puref, puref)
    }
    
    // MARK: - Helpers
    
    private func makeCore(
        _ amount: Decimal = 99_999.99,
        _ currency: String = anyMessage(),
        _ id: Int = generateRandom11DigitNumber()
    ) -> (amount: Decimal, currency: String, id: Int) {
        
        (amount, currency, id)
    }
}
