//
//  AnywayPaymentDigestPropertyTests.swift
//
//
//  Created by Igor Malyarov on 10.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentDigestPropertyTests: XCTestCase {
    
    func test_shouldSetAdditionalToEmptyOnEmptyElements() {
        
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssert(payment.digest.additional.isEmpty)
    }
    
    func test_shouldSetAdditionalToEmptyOnEmptyParameters() {
        
        let payment = makeAnywayPayment(fields: [makeAnywayPaymentField()])
        
        XCTAssert(payment.digest.additional.isEmpty)
    }
    
    func test_shouldNotSetAdditionalOnParameterWithNilValue() {
        
        let parameter = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(value: nil)
        )
        let payment = makeAnywayPayment(parameters: [parameter])
        
        XCTAssert(payment.digest.additional.isEmpty)
    }
    
    func test_shouldSetAdditionalOnParameter() {
        
        let (id, value) = (anyMessage(), anyMessage())
        let parameter = makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
                id: id, value: value
            )
        )
        let payment = makeAnywayPayment(parameters: [parameter])
        
        XCTAssertNoDiff(payment.digest.additional, [
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
        let payment = makeAnywayPayment(parameters: [parameter1, parameter2])
        
        XCTAssertNoDiff(payment.digest.additional, [
            .init(fieldID: 0, fieldName: id0, fieldValue: value0),
            .init(fieldID: 1, fieldName: id1, fieldValue: value1),
        ])
    }
    
    func test_shouldSetCoreToNilOnPaymentWithoutAmount() {
        
        let payment = makeAnywayPaymentWithoutAmount()
        
        XCTAssertNil(payment.digest.core)
    }
    
    func test_shouldSetCoreWithAccountIDOnPaymentWithAmount() {
        
        let (amount, currency, id) = makeCore()
        let payment = makeAnywayPaymentWithAmount(amount, currency, .accountID(.init(id)))
        
        XCTAssertNoDiff(payment.digest.core, .init(
            amount: amount,
            currency: .init(currency),
            productID: .account(.init(id))
        ))
    }
    
    func test_shouldSetCoreWithCardIDOnPaymentWithAmount() {
        
        let (amount, currency, id) = makeCore()
        let payment = makeAnywayPaymentWithAmount(amount, currency, .cardID(.init(id)))
        
        XCTAssertNoDiff(payment.digest.core, .init(
            amount: amount,
            currency: .init(currency),
            productID: .card(.init(id))
        ))
    }
    
    func test_shouldSetPuref() {
        
        let puref = anyMessage()
        let payment = makeAnywayPayment(puref: .init(puref))
        
        XCTAssertNoDiff(payment.digest.puref, .init(puref))
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
