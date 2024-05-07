//
//  PaymentsTransfersEffectHandlerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 28.02.2024.
//

@testable import ForaBank
import OperatorsListComponents
import XCTest

final class PaymentsTransfersEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, createAnywayTransferSpy, getOperatorsListByParamSpy) = makeSUT()
        
        XCTAssertEqual(createAnywayTransferSpy.callCount, 0)
        XCTAssertEqual(getOperatorsListByParamSpy.callCount, 0)
    }
    
    func test_getServicesFor_shouldCallGetOperatorsListByParamWithOperatorID() {
        
        let `operator` = makeOperator()
        let (sut, _, getOperatorsListByParamSpy) = makeSUT()
        
        sut.handleEffect(.utilityFlow(.getServicesFor(`operator`))) { _ in }
        
        XCTAssertNoDiff(getOperatorsListByParamSpy.payloads, [`operator`.id])
    }
    
    func test_getServicesFor_shouldDeliverFailureOnFailure() {
        
        let `operator` = makeOperator()
        let (sut, _, getOperatorsListByParamSpy) = makeSUT()
        
        expect(sut, with: .utilityFlow(.getServicesFor(`operator`)), toDeliver: .utilityFlow(.loaded(.failure, for: `operator`)), on: {
            
            getOperatorsListByParamSpy.complete(with: .failure)
        })
    }
    
    func test_getServicesFor_shouldDeliverListOnList() {
        
        let `operator` = makeOperator()
        let list = [makeService(), makeService()]
        let (sut, _, getOperatorsListByParamSpy) = makeSUT()
        
        expect(sut, with: .utilityFlow(.getServicesFor(`operator`)), toDeliver: .utilityFlow(.loaded(.list(list), for: `operator`)), on: {
            
            getOperatorsListByParamSpy.complete(with: .list(list))
        })
    }
    
    func test_getServicesFor_shouldDeliverSingleOnSingle() {
        
        let `operator` = makeOperator()
        let service = makeService()
        let (sut, _, getOperatorsListByParamSpy) = makeSUT()
        
        expect(sut, with: .utilityFlow(.getServicesFor(`operator`)), toDeliver: .utilityFlow(.loaded(.single(service), for: `operator`)), on: {
            
            getOperatorsListByParamSpy.complete(with: .single(service))
        })
    }
    
    func test_startPayment_shouldCallCreateAnywayTransferSpyWithPayload() {
        
        let payload = makeStartPaymentPayload()
        let (sut, createAnywayTransferSpy, _) = makeSUT()
        
        sut.handleEffect(.utilityFlow(.startPayment(payload))) { _ in }
        
        XCTAssertNoDiff(createAnywayTransferSpy.payloads, [payload])
    }
    
    func test_startPayment_shouldDeliverDetailsOnDetails() {
        
        let payload = makeStartPaymentPayload()
        let details = makePaymentDetails()
        let (sut, createAnywayTransferSpy, _) = makeSUT()
        
        expect(sut, with: .utilityFlow(.startPayment(payload)), toDeliver: .utilityFlow(.paymentStarted(.details(details))), on: {
            
            createAnywayTransferSpy.complete(with: .details(details))
        })
    }
    
    func test_startPayment_shouldDeliverFailureOnFailure() {
        
        let payload = makeStartPaymentPayload()
        let (sut, createAnywayTransferSpy, _) = makeSUT()
        
        expect(sut, with: .utilityFlow(.startPayment(payload)), toDeliver: .utilityFlow(.paymentStarted(.failure)), on: {
            
            createAnywayTransferSpy.complete(with: .failure)
        })
    }
    
    func test_startPayment_shouldDeliverServerErrorOnServerError() {
        
        let payload = makeStartPaymentPayload()
        let message = UUID().uuidString
        let (sut, createAnywayTransferSpy, _) = makeSUT()
        
        expect(sut, with: .utilityFlow(.startPayment(payload)), toDeliver: .utilityFlow(.paymentStarted(.serverError(message))), on: {
            
            createAnywayTransferSpy.complete(with: .serverError(message))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersEffectHandler
    
    private typealias Effect = SUT.Effect
    private typealias Event = SUT.Event
    
    private typealias LatestPayment = OperatorsListComponents.LatestPayment
    private typealias Operator = OperatorsListComponents.Operator

    private typealias StartPaymentPayload = PaymentsTransfersEffect.UtilityServicePaymentFlowEffect.StartPaymentPayload<LatestPayment, Operator>
    
    private typealias CreateAnywayTransferSpy = ProcessSpy<StartPaymentPayload, PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.PaymentStarted>
    private typealias GetOperatorsListByParamSpy = ProcessSpy<String, PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.GetOperatorsListByParamResponse>
    
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
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeOperator(
        _ id: String = UUID().uuidString
    ) -> Operator {
        
        .init(id: id, title: id, subtitle: nil, image: nil)
    }
    
    private func makeLatestPayment(
        _ title: String = UUID().uuidString
    ) -> LatestPayment {
        
        .init(image: nil, title: title, amount: "")
    }
    
    private func makeStartPaymentPayload(
        _ id: String = UUID().uuidString
    ) -> StartPaymentPayload {
        
        .latestPayment(makeLatestPayment(id))
    }
    
    private func makeService(
        _ id: String = UUID().uuidString
    ) -> UtilityService {
        
        .init(id: id)
    }
    
    private func makePaymentDetails(
        _ value: String = UUID().uuidString
    ) -> PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.PaymentStarted.PaymentDetails {
        
        .init()
    }
}
