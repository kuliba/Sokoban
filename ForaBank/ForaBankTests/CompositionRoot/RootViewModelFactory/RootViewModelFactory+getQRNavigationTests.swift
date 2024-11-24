//
//  RootViewModelFactory+getQRNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_getQRNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - outside
    
    func test_outside_shouldDeliverChatOnChat() {
        
        expect(with: .outside(.chat), toDeliver: .outside(.chat))
    }
    
    func test_outside_shouldDeliverMainOnMain() {
        
        expect(with: .outside(.main), toDeliver: .outside(.main))
    }
    
    func test_outside_shouldDeliverPaymentsOnPayments() {
        
        expect(with: .outside(.payments), toDeliver: .outside(.payments))
    }
    
    // MARK: - qrResult
    
    func test_c2bSubscribe_shouldDeliverPayments() {
        
        expect(with: .qrResult(.c2bSubscribeURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnClose() {
        
        expect(with: .c2bSubscribeURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnScanQR() {
        
        expect(with: .c2bSubscribeURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2b_shouldDeliverPayments() {
        
        expect(with: .qrResult(.c2bURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2b_shouldNotifyWithDismissOnClose() {
        
        expect(with: .c2bURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2b_shouldNotifyWithDismissOnScanQR() {
        
        expect(with: .c2bURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias NotifySpy = CallSpy<QRScannerDomain.NotifyEvent, Void>
    private typealias NavigationSpy = Spy<Void, QRScannerDomain.Navigation, Never>
    
    private func _makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        notifySpy: NotifySpy,
        navigationSpy: NavigationSpy
    ) {
        let notifySpy = NotifySpy()
        let navigationSpy = NavigationSpy()
        let sut = super.makeSUT().sut
        
        trackForMemoryLeaks(notifySpy, file: file, line: line)
        trackForMemoryLeaks(navigationSpy, file: file, line: line)
        
        return (sut, notifySpy, navigationSpy)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with select: QRScannerDomain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getQRNavigation(select: select, notify: { _ in }) { [self] in
            
            XCTAssertNoDiff(equatable($0), expectedNavigation, "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func equatable(
        _ navigation: QRScannerDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .outside(outside):
            return .outside(outside)
            
        case .payments:
            return .payments
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case outside(QRScannerDomain.Outside)
        case payments
    }
    
    private func makePayments(
        payload: PaymentsViewModel.Payload = .category(.fast),
        model: Model = .mockWithEmptyExcept(),
        closeAction: @escaping () -> Void = {}
    ) -> PaymentsViewModel {
        
        return .init(payload: payload, model: model, closeAction: closeAction)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with qrResult: QRModelResult,
        notifiesWith expectedNotifyEvent: QRScannerDomain.NotifyEvent,
        on action: @escaping (QRScannerDomain.Navigation) -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getQRNavigation(
            select: .qrResult(qrResult),
            notify: {
                
                XCTAssertNoDiff($0, expectedNotifyEvent, "Expected \(expectedNotifyEvent), got \($0) instead.", file: file, line: line)
            },
            completion: {
                
                action($0)
                exp.fulfill() }
        )
        
        wait(for: [exp], timeout: timeout)
    }
}
