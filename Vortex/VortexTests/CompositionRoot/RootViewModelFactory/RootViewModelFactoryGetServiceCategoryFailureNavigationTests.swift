//
//  RootViewModelFactoryGetServiceCategoryFailureNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactoryGetServiceCategoryFailureNavigationTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverDetailPaymentOnDetailPayment() {
        
        let sut = makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            select: Select.detailPayment,
            notify: { _ in }
        ) {
            switch $0 {
            case .detailPayment: break
            default: XCTFail("Expected detail payment, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldNotifyWithDismissOnDetailPaymentClose() {
        
        let sut = makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = 2
        
        sut.getNavigation(
            select: Select.detailPayment,
            notify: {
                
                XCTAssertNoDiff($0, .dismiss)
                exp.fulfill()
            }
        ) {
            $0.detailPayment?.closeAction()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverScanQROnScanQR() {
        
        let sut = makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            select: Select.scanQR,
            notify: { _ in }
        ) {
            switch $0 {
            case .scanQR: break
            default: XCTFail("Expected scanQR, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Select = ServiceCategoryFailureDomain.Select
}

// MARK: - DSL

extension ServiceCategoryFailureDomain.Navigation {
    
    var detailPayment: PaymentsViewModel? {
        
        guard case let .detailPayment(node) = self
        else { return nil }
        
        return node.model
    }
}
