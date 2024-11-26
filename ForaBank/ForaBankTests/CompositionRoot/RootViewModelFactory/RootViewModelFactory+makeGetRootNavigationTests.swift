//
//  RootViewModelFactory+makeGetRootNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeGetRootNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - scanQR
    
    func test_scanQR_shouldDeliverQRScanner() {
        
        expect(.scanQR, toDeliver: .scanQR)
    }
    
    // MARK: - templates
    
    func test_templates_shouldDeliverTemplates() {
        
        expect(.templates, toDeliver: .templates)
    }
    
    // MARK: - Helpers
    
    private typealias NotifyEvent = RootViewDomain.FlowDomain.NotifyEvent
    private typealias NotifySpy = CallSpy<NotifyEvent, Void>
    
    private func equatable(
        _ navigation: RootViewNavigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .scanQR:    return .scanQR
        case .templates: return .templates
        }
    }
    
    private enum EquatableNavigation {
        
        case scanQR
        case templates
    }
    
    private func expect(
        _ select: RootViewSelect,
        toDeliver expectedNavigation: EquatableNavigation,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT().sut
        let getNavigation = sut.makeGetRootNavigation()
        let exp = expectation(description: "wait for completion")
        
        getNavigation(select, { _ in }) {
            
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
