//
//  PaymentProviderPickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider> {
    
    let initiatePayment: InitiatePayment
    let makePayByInstructions: MakePayByInstructions
}

extension PaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload<Latest>, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void
}

enum InitiatePaymentPayload<Latest> {
    
    case latest(Latest)
}

extension InitiatePaymentPayload: Equatable where Latest: Equatable {}

final class PaymentProviderPickerFlowEffectHandler<Latest, Payment, PayByInstructions, Provider> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider>
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
                        
                    case let .success(payment):
                        dispatch(.paymentInitiated(payment))
                    }
                }
            case .payByInstructions:
                microServices.makePayByInstructions { dispatch(.payByInstructions($0))}
                
            case let .provider(provider):
                break
            }
        }
    }
}

extension PaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

import XCTest

final class PaymentProviderPickerFlowEffectHandlerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, initiatePayment, payByInstructions) = makeSUT()
        
        XCTAssertEqual(initiatePayment.callCount, 0)
        XCTAssertEqual(payByInstructions.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_latest_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment, _) = makeSUT()
        
        sut.handleEffect(.select(.latest(latest))) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [.latest(latest)])
    }
    
    func test_select_latest_shouldDeliverServiceFailureOnServiceFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment, _) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .initiatePaymentFailure(failure)) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_select_latest_shouldDeliverPaymentOnSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _) = makeSUT()
        
        expect(sut, with: .select(.latest(makeLatest())), toDeliver: .paymentInitiated(payment)) {
            
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    func test_select_payByInstructions_shouldDeliverPayByInstructions() {
        
        let payByInstructions = makePayByInstructions()
        let (sut, _, payByInstructionsSpy) = makeSUT()
        
        expect(sut, with: .select(.payByInstructions), toDeliver: .payByInstructions(payByInstructions)) {
            
            payByInstructionsSpy.complete(with: payByInstructions)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowEffectHandler<Latest, Payment, PayByInstructions, Provider>
    private typealias InitiatePaymentSpy = Spy<InitiatePaymentPayload<Latest>, SUT.MicroServices.InitiatePaymentResult>
    private typealias PayByInstructionsSpy = Spy<Void, PayByInstructions>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy,
        payByInstructions: PayByInstructionsSpy
    ) {
        let initiatePayment = InitiatePaymentSpy()
        let payByInstructions = PayByInstructionsSpy()
        let sut = SUT(microServices: .init(
            initiatePayment: initiatePayment.process(_:completion:),
            makePayByInstructions: payByInstructions.process(completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(payByInstructions, file: file, line: line)
        
        return (sut, initiatePayment, payByInstructions)
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
