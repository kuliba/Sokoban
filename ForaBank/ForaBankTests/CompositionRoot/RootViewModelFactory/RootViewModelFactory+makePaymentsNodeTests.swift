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
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .category(.fast)) {
            notifyCloseCount += 1
        }
        
        node.close()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
    
    func test_notify_shouldCallOnClose_service() {
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .service(.abroad)) {
            notifyCloseCount += 1
        }
        
        node.close()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
    
    func test_notify_shouldCallOnClose_source() {
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .source(.avtodor)) {
            notifyCloseCount += 1
        }
        
        node.close()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_category() {
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .category(.fast)) {
            notifyCloseCount += 1
        }
        
        node.scanQR()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_service() {
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .service(.abroad)) {
            notifyCloseCount += 1
        }
        
        node.scanQR()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
    
    func test_notify_shouldCallOnScanQR_source() {
        
        let sut = makeSUT().sut
        var notifyCloseCount = 0
        let node = sut.makePaymentsNode(payload: .source(.avtodor)) {
            notifyCloseCount += 1
        }
        
        node.scanQR()
        
        XCTAssertGreaterThan(notifyCloseCount, 0)
    }
}
