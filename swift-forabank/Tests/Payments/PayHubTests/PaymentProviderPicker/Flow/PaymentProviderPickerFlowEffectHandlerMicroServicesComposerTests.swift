//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import XCTest

final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment, _,_,_) = makeSUT()
        
        sut.initiatePayment(latest) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [.latest(latest)])
    }
    
    func test_initiatePayment_shouldDeliverFailureOnFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment, _,_,_) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .failure(failure)) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_initiatePayment_shouldDeliverSuccessOnSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _,_,_) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .success(payment)) {
            
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    // MARK: - makePayByInstructions
    
    func test_makePayByInstructions_shouldCallMakePayByInstructionsWithPayload() {
        
        let (sut, _, makePayByInstructions, _,_) = makeSUT()
        
        sut.makePayByInstructions { _ in }
        
        XCTAssertEqual(makePayByInstructions.callCount, 1)
    }
    
    func test_makePayByInstructions_shouldDeliverPayByInstructions() {
        
        let payByInstructions = makePayByInstructions()
        let (sut, _, payByInstructionsSpy, _,_) = makeSUT()
        
        expect(sut.makePayByInstructions, toDeliver: payByInstructions) {
            
            payByInstructionsSpy.complete(with: payByInstructions)
        }
    }
    
    // MARK: - processProvider
    
    func test_processProvider_shouldCallGetServiceCategoryListWithPayload() {
        
        let provider = makeProvider()
        let (sut, _,_, getServiceCategoryList, _) = makeSUT()
        
        sut.processProvider(provider) { _ in }
        
        XCTAssertNoDiff(getServiceCategoryList.payloads, [provider])
    }
    
    func test_processProvider_shouldDeliverServicesFailureOnServicesFailure() {
        
        let failure = makeServicesFailure()
        
        let (sut, _,_, getServiceCategoryList, makeServicesFailure) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicesResult(.servicesFailure(failure))) {
            
            getServiceCategoryList.complete(with: .failure(anyError()))
            makeServicesFailure.complete(with: failure)
        }
    }
    
    func test_processProvider_shouldDeliverServicesFailureOnEmptyServices() {
        
        let failure = makeServicesFailure()
        let (sut, _,_, getServiceCategoryList, makeServicesFailure) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicesResult(.servicesFailure(failure))) {
            
            getServiceCategoryList.complete(with: .success([]))
            makeServicesFailure.complete(with: failure)
        }
    }
    
    func test_processProvider_shouldDeliverServicesOnMultipleServices() {
        
        let services = makeServices()
        let (sut, _,_, getServiceCategoryList, _) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicesResult(.services(services))) {
            
            getServiceCategoryList.complete(with: .success(services.elements))
        }
    }
    
    func test_processProvider_shouldCallInitiatePaymentWithPayload() {
        
        let service = makeService()
        let (sut, initiatePayment, _, getServiceCategoryList, _) = makeSUT()
        
        sut.processProvider(makeProvider()) { _ in }
        getServiceCategoryList.complete(with: .success([service]))
        
        XCTAssertNoDiff(initiatePayment.payloads, [.service(service)])
    }
    
    func test_processProvider_shouldDeliverFailureOnOneServiceAndInitiatePaymentFailure() {
        
        let failure = makeServiceFailure()
        let (sut, initiatePayment, _, getServiceCategoryList, _) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .initiatePaymentResult(.failure(failure))) {
            
            getServiceCategoryList.complete(with: .success([self.makeService()]))
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_processProvider_shouldDeliverPaymentOnOneServiceAndInitiatePaymentSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _, getServiceCategoryList, _) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .initiatePaymentResult(.success(payment))) {
            
            getServiceCategoryList.complete(with: .success([self.makeService()]))
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    func test_processProvider_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getServiceCategoryList: GetServiceCategoryListSpy
        (sut, _,_, getServiceCategoryList, _) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.processProvider(makeProvider()) { _ in exp.fulfill() }
        sut = nil
        getServiceCategoryList.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure>
    private typealias SUT = Composer.MicroServices
    private typealias GetServiceCategoryListSpy = Spy<Provider, Result<[Service], Error>>
    private typealias InitiatePaymentSpy = Spy<InitiatePaymentPayload<Latest, Service>, SUT.InitiatePaymentResult>
    private typealias PayByInstructionsSpy = Spy<Void, PayByInstructions>
    private typealias MakeServicesFailureSpy = Spy<Void, ServicesFailure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy,
        payByInstructions: PayByInstructionsSpy,
        getServiceCategoryList: GetServiceCategoryListSpy,
        makeServicesFailure: MakeServicesFailureSpy
    ) {
        let getServiceCategoryList = GetServiceCategoryListSpy()
        let initiatePayment = InitiatePaymentSpy()
        let payByInstructions = PayByInstructionsSpy()
        let makeServicesFailure = MakeServicesFailureSpy()
        let composer = Composer(nanoServices: .init(
            getServiceCategoryList: getServiceCategoryList.process(_:completion:),
            initiatePayment: initiatePayment.process(_:completion:),
            makePayByInstructions: payByInstructions.process(completion:),
            makeServicesFailure: makeServicesFailure.process(completion:)
        ))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(payByInstructions, file: file, line: line)
        trackForMemoryLeaks(getServiceCategoryList, file: file, line: line)
        trackForMemoryLeaks(makeServicesFailure, file: file, line: line)
        
        return (sut, initiatePayment, payByInstructions, getServiceCategoryList, makeServicesFailure)
    }
    
    private func expect<Response>(
        _ sut: @escaping (@escaping (Response) -> Void) -> Void,
        toDeliver expectedResponses: Response...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) where Response: Equatable {
        
        expect({ _, completion in sut(completion) }, with: (), toDeliver: expectedResponses, on: action, file: file, line: line)
    }
    
    private func expect<Payload, Response>(
        _ sut: @escaping (Payload, @escaping (Response) -> Void) -> Void,
        with payload: Payload,
        toDeliver expectedResponses: Response...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) where Response: Equatable {
        
        expect(sut, with: payload, toDeliver: expectedResponses, on: action, file: file, line: line)
    }
    
    private func expect<Payload, Response>(
        _ sut: @escaping (Payload, @escaping (Response) -> Void) -> Void,
        with payload: Payload,
        toDeliver expectedResponses: [Response],
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
