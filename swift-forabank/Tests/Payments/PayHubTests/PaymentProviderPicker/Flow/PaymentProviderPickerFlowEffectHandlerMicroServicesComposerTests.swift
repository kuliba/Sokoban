//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

struct PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, Payment, PayByInstructions, Provider, Service> {
    
    public let initiatePayment: InitiatePayment
    public let makePayByInstructions: MakePayByInstructions
}

extension PaymentProviderPickerFlowEffectHandlerNanoServices {
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (Latest, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void
}

final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<Latest, Payment, PayByInstructions, Provider, Service> {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, Payment, PayByInstructions, Provider, Service>
}

extension PaymentProviderPickerFlowEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiatePayment: nanoServices.initiatePayment,
            makePayByInstructions: nanoServices.makePayByInstructions,
            processProvider: { _,_ in fatalError() }
        )
    }
    
    typealias MicroServices = PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider, Service>
}

import PayHub
import XCTest

final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment, _) = makeSUT()
        
        sut.initiatePayment(latest) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [latest])
    }
    
    func test_initiatePayment_shouldDeliverFailureOnFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment, _) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .failure(failure)) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_initiatePayment_shouldDeliverSuccessOnSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .success(payment)) {
            
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    // MARK: - makePayByInstructions
    
    func test_makePayByInstructions_shouldCallMakePayByInstructionsWithPayload() {
        
        let (sut, _, makePayByInstructions) = makeSUT()
        
        sut.makePayByInstructions { _ in }
        
        XCTAssertEqual(makePayByInstructions.callCount, 1)
    }
    
    func test_makePayByInstructions_shouldDeliverPayByInstructions() {
        
        let payByInstructions = makePayByInstructions()
        let (sut, _, payByInstructionsSpy) = makeSUT()
        
        expect(sut.makePayByInstructions, toDeliver: payByInstructions) {
            
            payByInstructionsSpy.complete(with: payByInstructions)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<Latest, Payment, PayByInstructions, Provider, Service>
    private typealias SUT = Composer.MicroServices
    private typealias InitiatePaymentSpy = Spy<Latest, SUT.InitiatePaymentResult>
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
        let composer = Composer(nanoServices: .init(
            initiatePayment: initiatePayment.process(_:completion:),
            makePayByInstructions: payByInstructions.process(completion:)
        ))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(payByInstructions, file: file, line: line)
        
        return (sut, initiatePayment, payByInstructions)
    }
    
    private func expect<Response>(
        _ sut: @escaping (@escaping (Response) -> Void) -> Void,
        toDeliver expectedResponses: Response...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) where Response: Equatable {
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedResponses.count
        var receivedResponses = [Response]()
        
        sut {
            
            receivedResponses.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedResponses, expectedResponses, "Expected \(expectedResponses), but got \(receivedResponses) instead.", file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect<Payload, Response>(
        _ sut: @escaping (Payload, @escaping (Response) -> Void) -> Void,
        with payload: Payload,
        toDeliver expectedResponses: Response...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) where Response: Equatable {
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedResponses.count
        var receivedResponses = [Response]()
        
        sut(payload) {
            
            receivedResponses.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedResponses, expectedResponses, "Expected \(expectedResponses), but got \(receivedResponses) instead.", file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
