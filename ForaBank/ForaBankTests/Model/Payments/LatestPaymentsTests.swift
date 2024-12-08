//
//  LatestPaymentsTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 08.09.2023.
//

import XCTest
@testable import ForaBank

final class LatestPaymentsTests: XCTestCase {
    
    func test_getServiceIdentifierWithTaxLatestPaymentFNS_shouldReturnPaymentServiceFNS() throws {
        
        let sut = makeSUT(serviceIdentifier: .fns)
        
        let latestPayment = try XCTUnwrap(sut.latestPayment)
        
        let taxService = try latestPayment.getServiceIdentifierForTaxService()
        
        XCTAssertNoDiff(taxService, .fns)
    }
    
    func test_getServiceIdentifierWithTaxLatestPaymentFMS_shouldReturnPaymentServiceFMS() throws {
        
        let sut = makeSUT(serviceIdentifier: .fms)
        
        let latestPayment = try XCTUnwrap(sut.latestPayment)
        
        let taxService = try latestPayment.getServiceIdentifierForTaxService()
        
        XCTAssertNoDiff(taxService, .fms)
    }
    
    func test_getServiceIdentifierWithTaxLatestPaymentFnsUin_shouldReturnPaymentServiceFNS() throws {
        
        let sut = makeSUT(serviceIdentifier: .fnsUin)
        
        let latestPayment = try XCTUnwrap(sut.latestPayment)
        
        let taxService = try latestPayment.getServiceIdentifierForTaxService()
        
        XCTAssertNoDiff(taxService, .fns)
    }
    
    func test_getServiceIdentifierWithTaxLatestPaymentFSSP_shouldReturnPaymentServiceFSSP() throws {
        
        let sut = makeSUT(serviceIdentifier: .fssp)
        
        let latestPayment = try XCTUnwrap(sut.latestPayment)
        
        let taxService = try latestPayment.getServiceIdentifierForTaxService()
        
        XCTAssertNoDiff(taxService, .fssp)
    }
    
    // MARK: Helpers
    
    func makeSUT(serviceIdentifier: ServiceIdentifier) -> Model {
        
        let model = Model.mockWithEmptyExcept()
        
        let latestPayment = PaymentServiceData(
            additionalList: [],
            amount: 10,
            date: Date(),
            paymentDate: "paymentDate",
            puref: serviceIdentifier.rawValue,
            type: .taxAndStateService,
            lastPaymentName: "lastPaymentName"
        )
        
        model.latestPayments.value = [latestPayment]
        
        return model
    }
    
    enum ServiceIdentifier: String {
        
        case fssp   = "iVortex||5429"
        case fms    = "iVortex||6887"
        case fns    = "iVortex||6273"
        case fnsUin = "iVortex||7069"
    }
}

private extension Model {
    
    var latestPayment: LatestPaymentData? { latestPayments.value.first }
}
