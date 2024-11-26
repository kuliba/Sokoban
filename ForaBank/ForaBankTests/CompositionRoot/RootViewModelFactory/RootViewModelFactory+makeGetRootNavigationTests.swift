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
    
    func test_scanQR_shouldNotifyWithDismissOnCancel() {
        
        let sut = makeSUT().sut
        let notifySpy = NotifySpy(stubs: [()])
        let getNavigation = sut.makeGetRootNavigation()
        let exp = expectation(description: "wait for completion")
        
        getNavigation(.scanQR, notifySpy.call) {
            
            switch $0 {
            case let .scanQR(node):
                node.model.content.event(.cancel)
                
            default:
                XCTFail("Expected QRScanner, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, [.dismiss])
    }
    
    // MARK: - templates
    
    func test_templates_shouldDeliverTemplates() {
        
        expect(.templates, toDeliver: .templates)
    }
    
    func test_templates_shouldNotifyWithDismissOnDismissAction() {
        
        let sut = makeSUT().sut
        let notifySpy = NotifySpy(stubs: [()])
        let getNavigation = sut.makeGetRootNavigation()
        let exp = expectation(description: "wait for completion")
        
        getNavigation(.templates, notifySpy.call) {
            
            switch $0 {
            case let .templates(node):
                node.model.state.content.dismissAction()
                
            default:
                XCTFail("Expected Templates, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, [.dismiss])
    }
    
    func test_templates_shouldNotifyWithMainTabOnMainTabStatus() {
        
        let sut = makeSUT().sut
        let notifySpy = NotifySpy(stubs: [()])
        let getNavigation = sut.makeGetRootNavigation()
        let exp = expectation(description: "wait for completion")
        
        getNavigation(.templates, notifySpy.call) {
            
            switch $0 {
            case let .templates(node):
                node.model.event(.flow(.init(status: .tab(.main))))
                
            default:
                XCTFail("Expected Templates, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, [.select(.tab(.main))])
    }
    
    func test_templates_shouldNotifyWithPaymentsTabOnPaymentsTabStatus() {
        
        let sut = makeSUT().sut
        let notifySpy = NotifySpy(stubs: [()])
        let getNavigation = sut.makeGetRootNavigation()
        let exp = expectation(description: "wait for completion")
        
        getNavigation(.templates, notifySpy.call) {
            
            switch $0 {
            case let .templates(node):
                node.model.event(.flow(.init(status: .tab(.payments))))
                
            default:
                XCTFail("Expected Templates, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, [.select(.tab(.payments))])
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

// MARK: - DSL

extension RootViewNavigation {
    
    func scanner(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> QRScanner {
        
        switch self {
        case let .scanQR(node):
            let qrScanner = node.model.content.qrScanner
            return try XCTUnwrap(qrScanner as? QRViewModel, "Expected QRScanner as QRViewModel.", file: file, line: line)
            
        default:
            XCTFail("Expected QRScanner, but got \(self) instead.", file: file, line: line)
            throw NSError(domain: "Expected QRScanner, but got \(self) instead.", code: -1)
        }
    }
}
