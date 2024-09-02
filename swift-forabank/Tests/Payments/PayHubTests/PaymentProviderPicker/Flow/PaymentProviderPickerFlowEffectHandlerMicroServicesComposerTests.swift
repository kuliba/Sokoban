//
//  PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools
import PayHub
import XCTest

final class PaymentProviderPickerFlowEffectHandlerMicroServicesComposerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallInitiatePaymentWithPayload() {
        
        let latest = makeLatest()
        let (sut, initiatePayment, _,_,_,_) = makeSUT()
        
        sut.initiatePayment(latest) { _ in }
        
        XCTAssertNoDiff(initiatePayment.payloads, [.latest(latest)])
    }
    
    func test_initiatePayment_shouldDeliverFailureOnFailure() {
        
        let failure = makeBackendFailure()
        let (sut, initiatePayment, _,_,_,_) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .backendFailure(failure)) {
            
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_initiatePayment_shouldDeliverSuccessOnSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _,_,_,_) = makeSUT()
        
        expect(sut.initiatePayment, with: makeLatest(), toDeliver: .payment(payment)) {
            
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    // MARK: - makeDetailPayment
    
    func test_makeDetailPayment_shouldCallMakeDetailPaymentWithPayload() {
        
        let (sut, _, makeDetailPayment, _,_,_) = makeSUT()
        
        sut.makeDetailPayment { _ in }
        
        XCTAssertEqual(makeDetailPayment.callCount, 1)
    }
    
    func test_makeDetailPayment_shouldDeliverDetailPayment() {
        
        let detailPayment = makeDetailPayment()
        let (sut, _, detailPaymentSpy, _,_,_) = makeSUT()
        
        expect(sut.makeDetailPayment, toDeliver: .detailPayment(detailPayment)) {
            
            detailPaymentSpy.complete(with: detailPayment)
        }
    }
    
    // MARK: - processProvider
    
    func test_processProvider_shouldCallGetServiceCategoryListWithPayload() {
        
        let provider = makeProvider()
        let (sut, _,_, getServiceCategoryList, _,_) = makeSUT()
        
        sut.processProvider(provider) { _ in }
        
        XCTAssertNoDiff(getServiceCategoryList.payloads, [provider])
    }
    
    func test_processProvider_shouldCallMakeServicePickerWithPayload() {
        
        let services = makeServices()
        let (sut, _,_, getServiceCategoryList, makeServicePicker, _) = makeSUT()
        
        sut.processProvider(makeProvider()) { _ in }
        getServiceCategoryList.complete(with: .success(services.elements))
        
        XCTAssertNoDiff(makeServicePicker.payloads, [services])
    }
    
    func test_processProvider_shouldDeliverServicePickerOnMultipleServices() {
        
        let services = makeServices()
        let picker = makeServicePicker()
        let (sut, _,_, getServiceCategoryList, makeServicePicker, _) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicePicker(picker)) {
            
            getServiceCategoryList.complete(with: .success(services.elements))
            makeServicePicker.complete(with: picker)
        }
    }
    
    func test_processProvider_shouldDeliverServicesFailureOnServicesFailure() {
        
        let failure = makeServicesFailure()
        
        let (sut, _,_, getServiceCategoryList, _, makeServicesFailure) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicesFailure(failure)) {
            
            getServiceCategoryList.complete(with: .failure(anyError()))
            makeServicesFailure.complete(with: failure)
        }
    }
    
    func test_processProvider_shouldDeliverServicesFailureOnEmptyServices() {
        
        let failure = makeServicesFailure()
        let (sut, _,_, getServiceCategoryList, _, makeServicesFailure) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .servicesFailure(failure)) {
            
            getServiceCategoryList.complete(with: .success([]))
            makeServicesFailure.complete(with: failure)
        }
    }
    
    func test_processProvider_shouldCallInitiatePaymentWithPayload() {
        
        let service = makeService()
        let (sut, initiatePayment, _, getServiceCategoryList, _,_) = makeSUT()
        
        sut.processProvider(makeProvider()) { _ in }
        getServiceCategoryList.complete(with: .success([service]))
        
        XCTAssertNoDiff(initiatePayment.payloads, [.service(service)])
    }
    
    func test_processProvider_shouldDeliverFailureOnOneServiceAndInitiatePaymentFailure() {
        
        let failure = makeBackendFailure()
        let (sut, initiatePayment, _, getServiceCategoryList, _,_) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .backendFailure(failure)) {
            
            getServiceCategoryList.complete(with: .success([self.makeService()]))
            initiatePayment.complete(with: .failure(failure))
        }
    }
    
    func test_processProvider_shouldDeliverPaymentOnOneServiceAndInitiatePaymentSuccess() {
        
        let payment = makePayment()
        let (sut, initiatePayment, _, getServiceCategoryList, _,_) = makeSUT()
        
        expect(sut.processProvider, with: makeProvider(), toDeliver: .payment(payment)) {
            
            getServiceCategoryList.complete(with: .success([self.makeService()]))
            initiatePayment.complete(with: .success(payment))
        }
    }
    
    func test_processProvider_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getServiceCategoryList: GetServiceCategoryListSpy
        (sut, _,_, getServiceCategoryList, _,_) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.processProvider(makeProvider()) { _ in exp.fulfill() }
        sut = nil
        getServiceCategoryList.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentProviderPickerFlowEffectHandlerMicroServicesComposer<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure>
    private typealias SUT = Composer.MicroServices
    private typealias NanoServices = Composer.NanoServices
    private typealias GetServiceCategoryListSpy = Spy<Provider, Result<[Service], Error>>
    private typealias InitiatePaymentSpy = Spy<InitiatePaymentPayload<Latest, Service>, NanoServices.InitiatePaymentResult>
    private typealias DetailPaymentSpy = Spy<Void, DetailPayment>
    private typealias MakeServicesFailureSpy = Spy<Void, ServicesFailure>
    private typealias Services = MultiElementArray<Service>
    private typealias MakeServicePickerSpy = Spy<Services, ServicePicker>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiatePayment: InitiatePaymentSpy,
        detailPayment: DetailPaymentSpy,
        getServiceCategoryList: GetServiceCategoryListSpy,
        makeServicePicker: MakeServicePickerSpy,
        makeServicesFailure: MakeServicesFailureSpy
    ) {
        let getServiceCategoryList = GetServiceCategoryListSpy()
        let initiatePayment = InitiatePaymentSpy()
        let detailPayment = DetailPaymentSpy()
        let makeServicePicker = MakeServicePickerSpy()
        let makeServicesFailure = MakeServicesFailureSpy()
        let composer = Composer(nanoServices: .init(
            getServiceCategoryList: getServiceCategoryList.process(_:completion:),
            initiatePayment: initiatePayment.process(_:completion:),
            makeDetailPayment: detailPayment.process(completion:),
            makeServicePicker: makeServicePicker.process(_:completion:),
            makeServicesFailure: makeServicesFailure.process(completion:)
        ))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(initiatePayment, file: file, line: line)
        trackForMemoryLeaks(detailPayment, file: file, line: line)
        trackForMemoryLeaks(getServiceCategoryList, file: file, line: line)
        trackForMemoryLeaks(makeServicesFailure, file: file, line: line)
        trackForMemoryLeaks(makeServicePicker, file: file, line: line)
        
        return (sut, initiatePayment, detailPayment, getServiceCategoryList, makeServicePicker, makeServicesFailure)
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
