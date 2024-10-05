//
//  QRNavigationComposerMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.10.2024.
//

import CombineSchedulers
import Foundation
import SberQR

final class QRNavigationComposerMicroServicesComposer {
    
    private let model: Model
    private let createSberQRPayment: CreateSberQRPayment
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        createSberQRPayment: @escaping CreateSberQRPayment,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.createSberQRPayment = createSberQRPayment
        self.scheduler = scheduler
    }
    
    typealias CreateSberQRPayment = (MicroServices.MakePaymentCompletePayload, @escaping (Result<CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>) -> Void) -> Void
}

extension QRNavigationComposerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            makeInternetTV: makeInternetTV,
            makePayments: makePayments,
            makeQRFailure: makeQRFailure,
            makeQRFailureWithQR: makeQRFailureWithQR,
            makePaymentComplete: makePaymentComplete,
            makeProviderPicker: { _,_ in },
            makeOperatorSearch: { _,_ in },
            makeSberQR: { _,_ in },
            makeServicePicker: { _,_ in }
        )
    }
    
    typealias MicroServices = QRNavigationComposerMicroServices
}

private extension QRNavigationComposerMicroServicesComposer {
    
    func makeInternetTV(
        payload: MicroServices.MakeInternetTVPayload,
        completion: @escaping (InternetTVDetailsViewModel) -> Void
    ) {
        completion(.init(model: model, qrCode: payload.0, mapping: payload.1))
    }
    
    func makePayments(
        payload: MicroServices.MakePaymentsPayload,
        completion: @escaping (ClosePaymentsViewModelWrapper) -> Void
    ) {
        switch payload {
        case let .operationSource(source):
            completion(.init(model: model, source: source, scheduler: scheduler))
            
        case let .qrCode(qrCode):
            completion(.init(model: model, source: .requisites(qrCode: qrCode), scheduler: scheduler))
            
        case let .source(source):
            switch source.type {
            case .c2b:
                completion(.init(model: model, source: .c2b(source.url), scheduler: scheduler))
                
            case .c2bSubscribe:
                completion(.init(model: model, source: .c2bSubscribe(source.url), scheduler: scheduler))
            }
        }
    }
    
    func makeQRFailure(
        payload: MicroServices.MakeQRFailurePayload,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        completion(.init(model: model, addCompanyAction: payload.chat, requisitsAction: payload.detailPayment))
    }
    
    func makeQRFailureWithQR(
        payload: MicroServices.MakeQRFailureWithQRPayload,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        completion(.init(model: model, addCompanyAction: payload.chat, requisitsAction: { payload.detailPayment(payload.qrCode) }))
    }
    
    func makePaymentComplete(
        payload: MicroServices.MakePaymentCompletePayload,
        completion: @escaping (QRNavigation.PaymentCompleteResult) -> Void
    ) {
        createSberQRPayment(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                completion(.success(.init(paymentSuccess: success.success, self.model)))
            }
        }
    }
}

@testable import ForaBank
import SberQR
import XCTest

final class QRNavigationComposerMicroServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, createSberQRPayment) = makeSUT()
        
        XCTAssertEqual(createSberQRPayment.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - makeInternetTV
    
    func test_composed_makeInternetTV_shouldCompleteAndSetQRData() {
        
        let payload = makeMakeInternetTVPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeInternetTV(payload) {
                
                XCTAssertNoDiff($0.qrData, payload.0.rawData)
                completion()
            }
        }
    }
    
    // MARK: - makePayments
    
    func test_composed_makePayments_shouldCompleteWithOperationSource() {
        
        let payload = makeMakePaymentsOperationSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithQRCode() {
        
        let payload = makeMakePaymentsQRCodePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSource() {
        
        let payload = makeMakePaymentsC2BSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSubscribeSource() {
        
        let payload = makeMakePaymentsC2BSubscribeSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailure
    
    func test_composed_makeQRFailure_shouldComplete() {
        
        let payload = makeMakeQRFailurePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeQRFailure(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailureWithQR
    
    func test_composed_makeQRFailureWithQR_shouldComplete() {
        
        let payload = makeMakeQRFailureWithQRPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeQRFailureWithQR(payload) { _ in completion() }
        }
    }
    
    // MARK: - makePaymentComplete
    
    func test_composed_makePaymentComplete_shouldCallCreateSberQRPaymentWithPayload() {
        
        let payload = makeMakePaymentCompletePayload()
        let (sut, createSberQRPayment) = makeSUT()
        
        sut.compose().makePaymentComplete(payload) { _ in }
        
        XCTAssertNoDiff(createSberQRPayment.payloads.map(\.0), [payload.0])
        XCTAssertNoDiff(createSberQRPayment.payloads.map(\.1), [payload.1])
    }
    
    func test_composed_makePaymentComplete_shouldDeliverFailureOnCreateSberQRPaymentFailure() {
        
        let (payload, failure) = (makeMakePaymentCompletePayload(), makeErrorMessage())
        let (sut, createSberQRPayment) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.compose().makePaymentComplete(payload) {
            
            switch $0 {
            case let .failure(receivedFailure):
                XCTAssertNoDiff(receivedFailure, failure)
                
            default:
                XCTFail("Expected failure \(failure), got \($0) instead.")
            }
            exp.fulfill()
        }
        
        createSberQRPayment.complete(with: failure)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composed_makePaymentComplete_shouldPaymentCompleteOnCreateSberQRPaymentSuccess() {
        
        let payload = makeMakePaymentCompletePayload()
        let (sut, createSberQRPayment) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.compose().makePaymentComplete(payload) {
            
            switch $0 {
            case .success:
                break
                
            default:
                XCTFail("Expected success , got \($0) instead.")
            }
            exp.fulfill()
        }
        
        createSberQRPayment.complete(with: makeCreateSberQRPaymentResponse())
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposerMicroServicesComposer
    private typealias CreateSberQRPaymentSpy = Spy<SUT.MicroServices.MakePaymentCompletePayload, CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        createSberQRPayment: CreateSberQRPaymentSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let createSberQRPayment = CreateSberQRPaymentSpy()
        let sut = SUT(
            model: model,
            createSberQRPayment: createSberQRPayment.process(_:completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(createSberQRPayment, file: file, line: line)
        
        return (sut, createSberQRPayment)
    }
    
    private func makeMakeInternetTVPayload(
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> SUT.MicroServices.MakeInternetTVPayload {
        
        return (qrCode ?? makeQR(), qrMapping ?? makeQRMapping())
    }
    
    private func makeQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    private func makeQRMapping(
        parameters: [QRParameter] = [],
        operators: [QROperator] = []
    ) -> QRMapping {
        
        return .init(parameters: parameters, operators: operators)
    }
    
    private func makeMakePaymentsOperationSourcePayload(
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .operationSource(.avtodor)
    }
    
    private func makeMakePaymentsQRCodePayload(
        qrCode: QRCode? = nil
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .qrCode(qrCode ?? makeQR())
    }
    
    private func makeMakePaymentsC2BSourcePayload(
        url: URL = anyURL()
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .source(.c2b(url))
    }
    
    private func makeMakePaymentsC2BSubscribeSourcePayload(
        url: URL = anyURL()
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .source(.c2b(url))
    }
    
    private func makeMakeQRFailurePayload(
        chat: @escaping () -> Void = {},
        detailPayment: @escaping () -> Void = {}
    ) -> SUT.MicroServices.MakeQRFailurePayload {
        
        return .init(chat: chat, detailPayment: detailPayment)
    }
    
    private func makeMakeQRFailureWithQRPayload(
        qrCode: QRCode? = nil,
        chat: @escaping () -> Void = {},
        detailPayment: @escaping (QRCode) -> Void = { _ in }
    ) -> SUT.MicroServices.MakeQRFailureWithQRPayload {
        
        return .init(qrCode: qrCode ?? makeQR(), chat: chat, detailPayment: detailPayment)
    }
    
    private func makeMakePaymentCompletePayload(
        url: URL = anyURL(),
        state: SberQRConfirmPaymentState? = nil
    ) -> SUT.MicroServices.MakePaymentCompletePayload {
        
        return (url, state ?? makeSberQRConfirmPaymentState())
    }
    
    private func makeSberQRConfirmPaymentState(
    ) -> SberQRConfirmPaymentState {
        
        return .init(confirm: .editableAmount(.preview))
    }
    
    private func makeErrorMessage(
        title: String = anyMessage(),
        message: String = anyMessage()
    ) -> QRNavigation.ErrorMessage {
        
        return .init(title: title, message: message)
    }
    
    private func makeCreateSberQRPaymentResponse(
        parameters: [CreateSberQRPaymentResponse.Parameter] = [.dataLong(.init(id: .paymentOperationDetailId, value: .random(in: 1...100)))]
    ) -> CreateSberQRPaymentResponse {
        
        return .init(parameters: parameters)
    }
    
    private func expect(
        toComplete function: @escaping (@escaping () -> Void) -> Void,
        timeout: TimeInterval = 1
    ) {
        let exp = expectation(description: "wait for completion")
        
        function { exp.fulfill() }
        
        wait(for: [exp], timeout: timeout)
    }
}
