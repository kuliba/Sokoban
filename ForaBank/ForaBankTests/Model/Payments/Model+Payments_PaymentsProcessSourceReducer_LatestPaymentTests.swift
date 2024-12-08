//
//  Model+Payments_PaymentsProcessSourceReducer_LatestPaymentTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 13.08.2023.
//

@testable import Vortex
import XCTest

final class Model_Payments_PaymentsProcessSourceReducer_LatestPaymentTests: XCTestCase {

    func test_paymentsProcessSourceReducer_latestPayments_wrongLatestPaymentID_shouldReturnNil() {
        
        let (model, _) = makeSUT(
            puref: .contactIdentifier,
            for: .outside
        )
        
        let source: Payments.Operation.Source = .latestPayment(11)
        
        let value = model.paymentsProcessSourceReducer(
            service: .abroad,
            source: source,
            parameterId: .amountIdentifier
        )

        if (value != nil) {
            XCTFail("Payments.Parameter.Value error")
        }
    }
    
    func test_paymentsProcessSourceReducer_shouldReturnAmount() {
        
        let (model, source) = makeSUT(
            puref: .fmsIdentifier,
            for: .taxAndStateService
        )
        
        let value = model.paymentsProcessSourceReducer(
            service: .fms,
            source: source,
            parameterId: .amountIdentifier
        )

        XCTAssertEqual(
            model.latestPayments.value.map(\.type),
            [.taxAndStateService]
        )
        
        XCTAssertEqual(value, "10.0")
    }
    
    // MARK: - Helpers
    
    func makeSUT(
        additionalList: [PaymentServiceData.AdditionalListData] = [],
        date: Date = .distantPast,
        paymentDate: String = "0203",
        puref: String,
        amount: Double = 10,
        for type: LatestPaymentData.Kind,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        model: Model,
        source: Payments.Operation.Source
    ) {
        
        let model: Model = .mockWithEmptyExcept()
                
        let latestPayment = PaymentServiceData(
            additionalList: additionalList,
            amount: amount,
            date: date,
            paymentDate: paymentDate,
            puref: puref,
            type: type,
            lastPaymentName: "lastPaymentName"
        )
        
        model.latestPayments.value = [latestPayment]

        trackForMemoryLeaks(model, file: file, line: line)
        
        return (model, .latestPayment(latestPayment.id))
    }
}

private extension String {
    
    static let amountIdentifier = Payments.Operation.Parameter.Identifier.amount.rawValue
    static let contactIdentifier = CountryWithServiceData.Service.Code.contact.rawValue
    static let fmsIdentifier = Payments.Operator.fms.rawValue
}
