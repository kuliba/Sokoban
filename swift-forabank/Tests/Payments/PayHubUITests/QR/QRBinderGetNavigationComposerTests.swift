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
        notify: @escaping Notify,
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
    
    typealias FlowDomain = PayHubUI.FlowDomain<QRResult, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Navigation = QRNavigation<Payments>
}

enum QRNavigation<Payments> {
    
    case payments(Payments)
}

import PayHubUI
import XCTest

final class QRBinderGetNavigationComposerTests: QRBinderTests {
    
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
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments(payments)
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NavigationComposer
    
    private struct Spies {
        
        let makePayments: MakePayments
    }
    
    private func makeSUT(
        payments: Payments = .init(),
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
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.QRResult,
        toDeliver expectedNavigation: Navigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(qrResult: qrResult, notify: { _ in }) {
            
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
        self.getNavigation(qrResult: qrResult, notify: { _ in }, completion: { _ in })
    }
}
