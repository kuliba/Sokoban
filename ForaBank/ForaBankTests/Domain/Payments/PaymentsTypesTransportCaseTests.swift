//
//  PaymentsTypesTransportCaseTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsTypesTransportCaseTests: XCTestCase {
    
    func test_paymentsService_shouldHaveServiceTransportCaseWithRawValue() {
        
        let transport: Payments.Service = .transport
        
        XCTAssertEqual(transport.rawValue, "transport")
    }
    
    func test_paymentsOperationTransferType_shouldHaveTransportCaseWithRawValue() {
        
        let transport: Payments.Operation.TransferType  = .transport
        
        XCTAssertNotNil(transport)
    }
    
    func test_paymentsServiceOperators_shouldReturnTransport() {
        
        let transport: Payments.Service = .transport
        
        XCTAssertEqual(transport.operators, [.transport])
    }
    
    func test_paymentsServiceTransferType_shouldReturnTransport() {
        
        let transport: Payments.Service = .transport
        
        XCTAssertEqual(transport.transferType, .transport)
    }
    
    func test_paymentsCategoryGeneral_shouldContainTransport() {
        
        let category: Payments.Category = .general
        
        XCTAssertTrue(category.services.contains(.transport))
    }
    
    func test_paymentsCategoryFast_shouldNotContainTransport() {
        
        let category: Payments.Category = .fast
        
        XCTAssertFalse(category.services.contains(.transport))
    }
    
    func test_paymentsCategoryTaxes_shouldNotContainTransport() {
        
        let category: Payments.Category = .taxes
        
        XCTAssertFalse(category.services.contains(.transport))
    }
    
    func test_paymentsOperator_shouldHaveServiceTransportCaseWithRawValue() {
        
        let transport: Payments.Operator = .transport
        
        XCTAssertEqual(transport.rawValue, Purefs.transport)
    }
    
    func test_paymentsServicesOperators_shouldContainTransport() {
        
        XCTAssertTrue(Payments.paymentsServicesOperators.contains(.transport))
    }
    
    func test_operatorByPaymentsType_shouldReturnTransportOperator() {
        
        typealias PaymentsType = PTSectionPaymentsView.ViewModel.PaymentsType
        
        let paymentsType: PaymentsType = .transport
        let `operator` = Payments.operatorByPaymentsType(paymentsType)
        
        XCTAssertEqual(`operator`, .transport)
    }
}
