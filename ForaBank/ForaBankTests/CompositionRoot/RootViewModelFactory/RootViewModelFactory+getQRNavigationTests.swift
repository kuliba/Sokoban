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
        toDeliver expectedNavigation: QRScannerDomain.Navigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getQRNavigation(select: select, notify: { _ in }) { [self] in
            
            XCTAssertNoDiff(equatable($0), equatable(expectedNavigation), "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
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
            
        case let .payments(node):
            return .payments(.init(node.model))
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case outside(QRScannerDomain.Outside)
        case payments(ObjectIdentifier)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with select: QRScannerDomain.Select,
        notifiesWith expectedNotifyEvent: QRScannerDomain.NotifyEvent,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getQRNavigation(
            select: select,
            notify: {
                
                XCTAssertNoDiff($0, expectedNotifyEvent, "Expected \(expectedNotifyEvent), got \($0) instead.", file: file, line: line)
            },
            completion: { _ in exp.fulfill() }
        )
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
