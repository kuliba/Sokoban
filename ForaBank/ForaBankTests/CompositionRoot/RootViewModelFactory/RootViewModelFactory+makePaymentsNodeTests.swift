//
//  RootViewModelFactory+makePaymentsNodeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 24.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makePaymentsNodeTests: RootViewModelFactoryTests {
    
    // MARK: - close
    
    func test_notify_shouldCallOnClose_category() {
        
        let (node, spy) = makeSUT(payload: .category(.fast))
        
        node.close()
        
        XCTAssertNoDiff(spy.payloads, [.close])
    }
    
    func test_notify_shouldCallOnClose_service() {
        
        let (node, spy) = makeSUT(payload: .service(.abroad))
        
        node.close()
        
        XCTAssertNoDiff(spy.payloads, [.close])
    }
    
    func test_notify_shouldCallOnClose_source() {
        
        let (node, spy) = makeSUT(payload: .source(.avtodor))
        
        node.close()
        
        XCTAssertNoDiff(spy.payloads, [.close])
    }
    
    // MARK: - scanQR
    
    func test_notify_shouldCallOnScanQR_category() {
        
        let (node, spy) = makeSUT(payload: .category(.fast))
        
        node.scanQR()
        
        XCTAssertNoDiff(spy.payloads, [.scanQR])
    }
    
    func test_notify_shouldCallOnScanQR_service() {
        
        let (node, spy) = makeSUT(payload: .service(.abroad))
        
        node.scanQR()
        
        XCTAssertNoDiff(spy.payloads, [.scanQR])
    }
    
    func test_notify_shouldCallOnScanQR_source() {
        
        let (node, spy) = makeSUT(payload: .source(.avtodor))
        
        node.scanQR()
        
        XCTAssertNoDiff(spy.payloads, [.scanQR])
    }
    
    // MARK: - Helpers
    
    private typealias Node = ForaBank.Node<PaymentsViewModel>
    private typealias CloseSpy = CallSpy<SUT.PaymentsViewModelEvent, Void>
    
    private func makeSUT(
        payload: PaymentsViewModel.Payload,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        node: Node,
        spy: CloseSpy
    ) {
        let spy = CloseSpy(stubs: [()])
        let sut = super.makeSUT().sut
        let node = sut.makePaymentsNode(payload: payload, notify: spy.call)
        
        return (node, spy)
    }
}
