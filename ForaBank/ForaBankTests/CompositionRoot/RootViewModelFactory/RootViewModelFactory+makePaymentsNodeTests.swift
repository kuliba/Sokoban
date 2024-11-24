//
//  RootViewModelFactory+makePaymentsNodeTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makePaymentsNodeTests: RootViewModelFactoryTests {
    
    func test_notify_shouldCallOnClose_category() {
        
        let (node, spy) = makeSUT(payload: .category(.fast))
        
        node.close()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    func test_notify_shouldCallOnClose_service() {
        
        let (node, spy) = makeSUT(payload: .service(.abroad))
        
        node.close()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    func test_notify_shouldCallOnClose_source() {
        
        let (node, spy) = makeSUT(payload: .source(.avtodor))
        
        node.close()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_category() {
        
        let (node, spy) = makeSUT(payload: .category(.fast))
        
        node.scanQR()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_service() {
        
        let (node, spy) = makeSUT(payload: .service(.abroad))
        
        node.scanQR()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_source() {
        
        let (node, spy) = makeSUT(payload: .source(.avtodor))
        
        node.scanQR()
        
        XCTAssertGreaterThan(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias Node = ForaBank.Node<PaymentsViewModel>
    private typealias CloseSpy = CallSpy<Void, Void>
    
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
        let node = sut.makePaymentsNode(payload: payload, notifyClose: spy.call)
        
        return (node, spy)
    }
}
