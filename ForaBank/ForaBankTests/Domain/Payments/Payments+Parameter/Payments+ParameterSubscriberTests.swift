//
//  Payments+ParameterSubscriberTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 02.04.2024.
//

@testable import ForaBank
import XCTest

final class Payments_ParameterSubscriberTests: XCTestCase {
    
    func test_initC2BSubscriptionData_shouldSetParameterLegalName_valueLegalName() {
        
        let parameterSubscriber = Payments.ParameterSubscriber(
            with: C2BSubscriptionData.stub()
        )
        
        XCTAssertNoDiff(parameterSubscriber.value, "brandName")
        XCTAssertNoDiff(parameterSubscriber.description, "legalName")
    }
    
    
    func test_init_shouldSetParameterDescription_valueLegalNameSubscriptionPurpose() {
        
        let parameterSubscriber = Payments.ParameterSubscriber(with: PaymentParameterSubscriber.stub(legalName: "legalName")
        )
        
        XCTAssertNoDiff(parameterSubscriber.value, "value")
        XCTAssertNoDiff(parameterSubscriber.description, "legalName" + "\n" + "subscriptionPurpose")
    }
    
    func test_init_shouldSetParameterDescription_valueLegalNamNileSubscriptionPurpose() {
        
        let parameterSubscriber = Payments.ParameterSubscriber(with: PaymentParameterSubscriber.stub(legalName: nil)
        )
        
        XCTAssertNoDiff(parameterSubscriber.value, "value")
        XCTAssertNoDiff(parameterSubscriber.description, "subscriptionPurpose")
    }
}

private extension C2BSubscriptionData {
    
    static func stub() -> Self {
        .init(
            operationStatus: .complete,
            title: "title",
            brandIcon: "brandIcon",
            brandName: "brandName",
            legalName: "legalName",
            redirectUrl: nil
        )
    }
}

private extension PaymentParameterSubscriber {
    
    static func stub(
        legalName: String?
    ) -> Self {
        .init(
            id: "id",
            value: "value",
            icon: "icon",
            legalName: legalName,
            subscriptionPurpose: "subscriptionPurpose",
            style: .small
        )
    }
}
