//
//  PaymentsTransfersEffectHandlerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 28.02.2024.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, createAnywayTransferSpy, getOperatorsListByParamSpy) = makeSUT()
        
        XCTAssertEqual(createAnywayTransferSpy.callCount, 0)
        XCTAssertEqual(getOperatorsListByParamSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersEffectHandler
    private typealias CreateAnywayTransferSpy = ProcessSpy<PaymentsTransfersEffect.StartPaymentPayload, PaymentsTransfersEvent.PaymentStarted>
    private typealias GetOperatorsListByParamSpy = ProcessSpy<String, PaymentsTransfersEvent.GetOperatorsListByParamResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        createAnywayTransferSpy: CreateAnywayTransferSpy,
        getOperatorsListByParamSpy: GetOperatorsListByParamSpy
    ) {
        let createAnywayTransferSpy = CreateAnywayTransferSpy()
        let getOperatorsListByParamSpy = GetOperatorsListByParamSpy()
        
        let sut = SUT(
            createAnywayTransfer: createAnywayTransferSpy.process,
            getOperatorsListByParam: getOperatorsListByParamSpy.process)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(createAnywayTransferSpy, file: file, line: line)
        trackForMemoryLeaks(getOperatorsListByParamSpy, file: file, line: line)
        
        return (sut, createAnywayTransferSpy, getOperatorsListByParamSpy)
    }
}
