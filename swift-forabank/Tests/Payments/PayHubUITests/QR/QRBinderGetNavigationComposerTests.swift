//
//  QRBinderGetNavigationComposerTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHub

struct QRBinderGetNavigationComposerMicroServices<Payments> {
    
    let makePayments: MakePayments
}

extension QRBinderGetNavigationComposerMicroServices {
    
    typealias MakePayments = (MakePaymentsPayload) -> Payments
    
    enum MakePaymentsPayload: Equatable {
        
        case c2bSubscribe(URL)
    }
}

final class QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, Source> {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        self.microServices = microServices
    }
    
    typealias MicroServices = QRBinderGetNavigationComposerMicroServices<Payments>
}

extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        qrResult: QRResult,
        completion: @escaping (Navigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            let payments = microServices.makePayments(.c2bSubscribe(url))
            completion(.payments(payments))
            
        default:
            fatalError()
        }
    }
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Navigation = QRNavigation<Payments>
}

enum QRNavigation<Payments> {
    
    case payments(Payments)
}

import XCTest

final class QRBinderGetNavigationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makePayments.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribeURL
    
    func test_getNavigation_shouldCallMakePaymentsWithURLOnC2BSubscribe() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .c2bSubscribeURL(url))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.c2bSubscribe(url)])
    }
    
    func test_getNavigation_shouldDeliverPaymentsOnC2BSubscribe() {
        
        let payments = makePaymentsModel()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments(payments)
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRBinderGetNavigationComposer<Operator, Provider, PaymentsModel, QRCode, QRMapping, Source>
    private typealias MakePaymentsPayload = SUT.MicroServices.MakePaymentsPayload
    private typealias MakePayments = CallSpy<MakePaymentsPayload, PaymentsModel>
    
    private struct Spies {
        
        let makePayments: MakePayments
    }
    
    private func makeSUT(
        payments: PaymentsModel = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makePayments: .init(stubs: [payments])
        )
        let sut = SUT(microServices: .init(
            makePayments: spies.makePayments.call
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private struct Operator: Equatable {
        
        let value: String
    }
    
    private func makeOperator(
        _ value: String = anyMessage()
    ) -> Operator {
        
        return .init(value: value)
    }
    
    private struct Provider: Equatable {
        
        let value: String
    }
    
    private func makeProvider(
        _ value: String = anyMessage()
    ) -> Provider {
        
        return .init(value: value)
    }
    
    private struct QRCode: Equatable {
        
        let value: String
    }
    
    private func makeQRCode(
        _ value: String = anyMessage()
    ) -> QRCode {
        
        return .init(value: value)
    }
    
    private struct QRMapping: Equatable {
        
        let value: String
    }
    
    private func makeQRMapping(
        _ value: String = anyMessage()
    ) -> QRMapping {
        
        return .init(value: value)
    }
    
    private struct Source: Equatable {
        
        let value: String
    }
    
    private func makeSource(
        _ value: String = anyMessage()
    ) -> Source {
        
        return .init(value: value)
    }
    
    private final class PaymentsModel {}
    
    private func makePaymentsModel() -> PaymentsModel {
        
        return .init()
    }
    
    private enum EquatableNavigation: Equatable {
        
        case payments(ObjectIdentifier)
    }
    
    private func equatable(
        _ navigation: SUT.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .payments(payments):
            return .payments(.init(payments))
        }
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.QRResult,
        toDeliver expectedNavigation: SUT.Navigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(qrResult: qrResult) {
            
            XCTAssertNoDiff(self.equatable($0), self.equatable(expectedNavigation), "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

// MARK: - DSL

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        qrResult: QRResult
    ) {
        self.getNavigation(qrResult: qrResult, completion: { _ in })
    }
}
