//
//  PaymentsTransfersEffectHandlerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 28.02.2024.
//

@testable import Vortex
import OperatorsListComponents
import RemoteServices
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
    
    private typealias LatestPayment = UtilityPaymentLastPayment
    private typealias Operator = UtilityPaymentOperator

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
        _ id: String = anyMessage(),
        inn: String = anyMessage(),
        title: String = anyMessage(),
        icon: String? = nil,
        type: String = anyMessage()
    ) -> UtilityPaymentOperator {
        
        .init(id: id, inn: inn, title: title, icon: icon, type: type)
    }

    private func makeLatestPayment(
        date: Date = .init(),
        _ title: String = UUID().uuidString,
        _ icon: String = UUID().uuidString,
        _ puref: String = UUID().uuidString,
        additionalItems: [RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem] = []
    ) -> LatestPayment {
        
        return .init(date: date, amount: .init(Int.random(in: 0..<1_000)), name: title, md5Hash: UUID().uuidString, puref: UUID().uuidString, additionalItems: additionalItems)
    }
    
    private func makeStartPaymentPayload(
        _ id: String = UUID().uuidString
    ) -> StartPaymentPayload {
        
        .latestPayment(makeLatestPayment(id))
    }
    
    private func makeService(
        name: String = UUID().uuidString,
        _ puref: String = UUID().uuidString
    ) -> UtilityService {
        
        .init(name: name, puref: puref)
    }

    private func makePaymentDetails(
        _ value: String = UUID().uuidString
    ) -> PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.PaymentStarted.PaymentDetails {
        
        .init()
    }
}
