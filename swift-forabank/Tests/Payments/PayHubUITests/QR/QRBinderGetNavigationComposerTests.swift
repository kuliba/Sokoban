//
//  QRBinderGetNavigationComposerTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI
import XCTest

final class QRBinderGetNavigationComposerTests: QRBinderTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makePayments.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_getNavigation_c2bSubscribe_shouldCallMakePaymentsWithC2BSubscribeURL() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .c2bSubscribeURL(url))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.c2bSubscribe(url)])
    }
    
    func test_getNavigation_c2bSubscribe_shouldDeliverPayments() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments(.init(payments))
        )
    }
    
    func test_getNavigation_c2bSubscribe_shouldNotifyWithDismissOnPaymentsClose() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bSubscribeURL(anyURL()),
            notifyWith: [.dismiss],
            for: { $0.payments?.close() }
        )
    }
    
    // MARK: - c2b
    
    func test_getNavigation_c2b_shouldCallMakePaymentsWithC2BURL() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .c2bURL(url))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.c2b(url)])
    }
    
    func test_getNavigation_c2b_shouldDeliverPayments() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bURL(anyURL()),
            toDeliver: .payments(.init(payments))
        )
    }
    
    func test_getNavigation_c2b_shouldNotifyWithDismissOnPaymentsClose() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bURL(anyURL()),
            notifyWith: [.dismiss],
            for: { $0.payments?.close() }
        )
    }
    
    // MARK: - failure
    
    func test_getNavigation_failure_shouldCallMakeQRFailureWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .failure(qrCode))
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [qrCode])
    }
    
    func test_getNavigation_failure_shouldDeliverQRFailure() {
        
        let qrFailure = makeQRFailure()
        
        expect(
            makeSUT(qrFailure: qrFailure).sut,
            with: .failure(makeQRCode()),
            toDeliver: .qrFailure(.init(qrFailure))
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NavigationComposer
    
    private struct Spies {
        
        let makePayments: MakePayments
        let makeQRFailure: MakeQRFailure
    }
    
    private func makeSUT(
        payments: Payments? = nil,
        qrFailure: QRFailure? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makePayments: .init(stubs: [payments ?? makePayments()]),
            makeQRFailure: .init(stubs: [qrFailure ?? makeQRFailure()])
        )
        let sut = SUT(
            microServices: .init(
                makeQRFailure: spies.makeQRFailure.call,
                makePayments: spies.makePayments.call
            ),
            witnesses: .init(isClosed: { $0.isClosed })
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.QRResult,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(qrResult: qrResult, notify: { _ in }) {
            
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.QRResult,
        notifyWith expectedEvents: [SUT.FlowDomain.NotifyEvent],
        for destinationAction: @escaping (Navigation) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvents = [SUT.FlowDomain.NotifyEvent]()
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            qrResult: qrResult,
            notify: { receivedEvents.append($0) }
        ) {
            destinationAction($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedEvents, expectedEvents, "Expected \(expectedEvents), but got \(receivedEvents) instead.", file: file, line: line)
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

extension QRNavigation {
    
    var payments: Payments? {
        
        guard case let .payments(node) = self else { return nil }
        
        return node.model
    }
}
