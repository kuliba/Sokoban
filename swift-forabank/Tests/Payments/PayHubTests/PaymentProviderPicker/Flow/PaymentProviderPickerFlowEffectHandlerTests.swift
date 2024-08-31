//
//  PaymentProviderPickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Provider> {
    
    let initiatePayment: InitiatePayment
}

extension PaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias InitiatePaymentResult = Result<Void, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload<Latest>, @escaping InitiatePaymentCompletion) -> Void
}

enum InitiatePaymentPayload<Latest> {
    
    case latest(Latest)
}

extension InitiatePaymentPayload: Equatable where Latest: Equatable {}

final class PaymentProviderPickerFlowEffectHandler<Latest, Provider> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Provider>
}

extension PaymentProviderPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            switch select {
            case let .latest(latest):
                microServices.initiatePayment(.latest(latest)) {
                    switch $0 {
                    case let .failure(serviceFailure):
                        dispatch(.initiatePaymentFailure(serviceFailure))
                        
                    case let .success(success):
                        break
                    }
                }
            case .payByInstructions:
                break
            case let .provider(provider):
                break
            }
        }
    }
}

extension PaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

import XCTest

final class PaymentProviderPickerFlowEffectHandlerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, initiatePayment) = makeSUT()
        
        XCTAssertEqual(initiatePayment.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_latest_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment) = makeSUT()
        
        sut.handleEffect(.select(.latest(latest))) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [.latest(latest)])
    }
    
    func test_select_latest_shouldDeliverServiceFailureOnServiceFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .initiatePaymentFailure(failure)) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowEffectHandler<Latest, Provider>
    private typealias InitiatePaymentSpy = Spy<InitiatePaymentPayload<Latest>, SUT.MicroServices.InitiatePaymentResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy
    ) {
        let initiatePayment = InitiatePaymentSpy()
        let sut = SUT(microServices: .init(
            initiatePayment: initiatePayment.process(_:completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        
        return (sut, initiatePayment)
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
