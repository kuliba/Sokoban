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
            makeQRFailure: { _,_ in },
            makeQRFailureWithQR: { _,_ in },
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
}

@testable import ForaBank
import XCTest

final class QRNavigationComposerMicroServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let sut = makeSUT()
    }
    
    // MARK: - makeInternetTV
    
    func test_composed_makeInternetTV_shouldSetQRData() {
        
        let payload = makeMakeInternetTVPayload()
        let composed = makeSUT().compose()
        let exp = expectation(description: "wait for completion")
        
        composed.makeInternetTV(payload) {
            
            XCTAssertNoDiff($0.qrData, payload.0.rawData)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - makePayments
    
    func test_composed_makePayments_shouldDeliverPaymentsWithOperationSource() {
        
        let payload = makeMakePaymentsOperationSourcePayload()
        let composed = makeSUT().compose()
        let exp = expectation(description: "wait for completion")
        
        composed.makePayments(payload) { _ in
            
            // not really clear what else to test here
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composed_makePayments_shouldDeliverPaymentsWithQRCode() {
        
        let payload = makeMakePaymentsQRCodePayload()
        let composed = makeSUT().compose()
        let exp = expectation(description: "wait for completion")
        
        composed.makePayments(payload) { _ in
            
            // not really clear what else to test here
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composed_makePayments_shouldDeliverPaymentsWithC2BSource() {
        
        let payload = makeMakePaymentsC2BSourcePayload()
        let composed = makeSUT().compose()
        let exp = expectation(description: "wait for completion")
        
        composed.makePayments(payload) { _ in
            
            // not really clear what else to test here
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composed_makePayments_shouldDeliverPaymentsWithC2BSubscribeSource() {
        
        let payload = makeMakePaymentsC2BSubscribeSourcePayload()
        let composed = makeSUT().compose()
        let exp = expectation(description: "wait for completion")
        
        composed.makePayments(payload) { _ in
            
            // not really clear what else to test here
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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
}
