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
        
        let (sut, initiatePayment, detailPayment, providerProcess) = makeSUT()
        
        XCTAssertEqual(initiatePayment.callCount, 0)
        XCTAssertEqual(detailPayment.callCount, 0)
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
    
    func test_select_latest_shouldDeliverDestination() {
        
        let destination = makeDestination()
        let (sut, initiatePayment, _,_) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .destination(destination)) {
            
            initiatePayment.complete(with: destination)
        }
    }
    
    func test_select_detailPayment_shouldDeliverDestination() {
        
        let destination = makeDestination()
        let (sut, _, detailPaymentSpy,_) = makeSUT()
        
        expect(sut, with: .select(.detailPayment), toDeliver: .destination(destination)) {
            
            detailPaymentSpy.complete(with: destination)
        }
    }
    
    func test_select_provider_shouldCallProviderServiceWithPayload() {
        
        let provider = makeProvider()
        let (sut, _,_, providerProcess) = makeSUT()
        
        sut.handleEffect(.select(.provider(provider))) { _ in }
        
        XCTAssertNoDiff(providerProcess.payloads, [provider])
    }
    
    func test_select_provider_shouldDeliverServicePickerOnServicePicker() {
        
        let destination = makeDestination()
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .destination(destination)) {
            
            providerProcess.complete(with: destination)
        }
    }
    
    func test_select_provider_shouldDeliverInitiatePaymentFailureOnInitiatePaymentFailure() {
        
        let destination = makeDestination()
        let (sut, _,_, providerProcess) = makeSUT()
        
        expect(sut, with: .select(.provider(makeProvider())), toDeliver: .destination(destination)) {
            
            providerProcess.complete(with: destination)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowEffectHandler<Destination, Latest, Provider>
    private typealias InitiatePaymentSpy = Spy<Latest, Destination>
    private typealias DetailPaymentSpy = Spy<Void, Destination>
    private typealias ProviderSpy = Spy<Provider, Destination>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy,
        detailPayment: DetailPaymentSpy,
        providerSpy: ProviderSpy
    ) {
        let initiatePayment = InitiatePaymentSpy()
        let detailPayment = DetailPaymentSpy()
        let providerSpy = ProviderSpy()
        let sut = SUT(microServices: .init(
            initiatePayment: initiatePayment.process(_:completion:),
            makeDetailPayment: detailPayment.process(completion:),
            processProvider: providerSpy.process(_:completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(detailPayment, file: file, line: line)
        trackForMemoryLeaks(providerSpy, file: file, line: line)
        
        return (sut, initiatePayment, detailPayment, providerSpy)
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
