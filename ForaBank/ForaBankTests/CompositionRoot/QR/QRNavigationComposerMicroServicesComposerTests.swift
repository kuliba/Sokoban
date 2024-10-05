//
//  QRNavigationComposerMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.10.2024.
//

import CombineSchedulers
import Foundation

final class QRNavigationComposerMicroServicesComposer {
    
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.scheduler = scheduler
    }
}

extension QRNavigationComposerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            makeInternetTV: makeInternetTV,
            makePayments: makePayments,
            makeQRFailure: makeQRFailure,
            makeQRFailureWithQR: makeQRFailureWithQR,
            makePaymentComplete: { _,_ in },
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
}

@testable import ForaBank
import XCTest

final class QRNavigationComposerMicroServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let sut = makeSUT()
    }
    
    // MARK: - makeInternetTV
    
    func test_composed_makeInternetTV_shouldCompleteAndSetQRData() {
        
        let payload = makeMakeInternetTVPayload()
        let composed = makeSUT().compose()
        
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
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithQRCode() {
        
        let payload = makeMakePaymentsQRCodePayload()
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSource() {
        
        let payload = makeMakePaymentsC2BSourcePayload()
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSubscribeSource() {
        
        let payload = makeMakePaymentsC2BSubscribeSourcePayload()
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailure
    
    func test_composed_makeQRFailure_shouldComplete() {
        
        let payload = makeMakeQRFailurePayload()
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makeQRFailure(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailureWithQR
    
    func test_composed_makeQRFailureWithQR_shouldComplete() {
        
        let payload = makeMakeQRFailureWithQRPayload()
        let composed = makeSUT().compose()
        
        expect { completion in
            
            composed.makeQRFailureWithQR(payload) { _ in completion() }
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposerMicroServicesComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model: Model = .mockWithEmptyExcept()
        let sut = SUT(model: model, scheduler: .immediate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
    
    private func expect(
        toComplete function: @escaping (@escaping () -> Void) -> Void,
        timeout: TimeInterval = 1
    ) {
        let exp = expectation(description: "wait for completion")
        
        function { exp.fulfill() }
        
        wait(for: [exp], timeout: timeout)
    }
}
