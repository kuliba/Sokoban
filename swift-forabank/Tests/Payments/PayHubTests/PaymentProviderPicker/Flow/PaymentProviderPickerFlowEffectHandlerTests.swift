//
//  PaymentProviderPickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import PayHub
import XCTest

final class PaymentProviderPickerFlowEffectHandlerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, initiatePayment, payByInstructions, providerProcess) = makeSUT()
        
        XCTAssertEqual(initiatePayment.callCount, 0)
        XCTAssertEqual(payByInstructions.callCount, 0)
        XCTAssertEqual(providerProcess.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_latest_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment, _,_) = makeSUT()
        
        sut.handleEffect(.select(.latest(latest))) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [latest])
    }
    
    func test_select_latest_shouldDeliverServiceFailureOnServiceFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment, _,_) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .initiatePaymentResult(.failure(failure))) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_select_latest_shouldDeliverPaymentOnSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _,_) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .initiatePaymentResult(.success(payment))) {
            
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    func test_select_payByInstructions_shouldDeliverPayByInstructions() {
        
        let payByInstructions = makePayByInstructions()
        let (sut, _, payByInstructionsSpy,_) = makeSUT()
        
        expect(sut, with: .select(.payByInstructions), toDeliver: .payByInstructions(payByInstructions)) {
            
            payByInstructionsSpy.complete(with: payByInstructions)
        }
    }
    
    func test_select_provider_shouldCallProviderServiceWithPayload() {
        
        let provider = makeProvider()
        let (sut, _,_, providerProcess) = makeSUT()
        
        sut.handleEffect(.select(.provider(provider))) { _ in }
        
        XCTAssertNoDiff(providerProcess.payloads, [provider])
    }
    
    func test_select_provider_shouldDeliverServicesOnServices() {
        
        let services = makeServices()
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .loadServices(services)) {
            
            providerProcess.complete(with: .services(services))
        }
    }
    
    func test_select_provider_shouldDeliverInitiatePaymentFailureOnInitiatePaymentFailure() {
        
        let failure = makeServiceFailure()
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .initiatePaymentResult(.failure(failure))) {
            
            providerProcess.complete(with: .initiatePaymentResult(.failure(failure)))
        }
    }
    
    func test_select_provider_shouldDeliverPaymentOnPayment() {
        
        let payment = makePayment()
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .initiatePaymentResult(.success(payment))) {
            
            providerProcess.complete(with: .initiatePaymentResult(.success(payment)))
        }
    }
    
    func test_select_provider_shouldDeliverServicesFailureOnPrividerServicesFailure() {
        
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .loadServices(nil)) {
            
            providerProcess.complete(with: .servicesFailure)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowEffectHandler<Latest, Payment, PayByInstructions, Provider, Service>
    private typealias InitiatePaymentSpy = Spy<Latest, SUT.MicroServices.InitiatePaymentResult>
    private typealias PayByInstructionsSpy = Spy<Void, PayByInstructions>
    private typealias ProviderSpy = Spy<Provider, ProcessProviderResult<Payment, Service>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy,
        payByInstructions: PayByInstructionsSpy,
        providerSpy: ProviderSpy
    ) {
        let initiatePayment = InitiatePaymentSpy()
        let payByInstructions = PayByInstructionsSpy()
        let providerSpy = ProviderSpy()
        let sut = SUT(microServices: .init(
            initiatePayment: initiatePayment.process(_:completion:),
            makePayByInstructions: payByInstructions.process(completion:),
            processProvider: providerSpy.process(_:completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(payByInstructions, file: file, line: line)
        trackForMemoryLeaks(providerSpy, file: file, line: line)
        
        return (sut, initiatePayment, payByInstructions, providerSpy)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
