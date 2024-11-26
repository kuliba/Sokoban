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
        
        expect(.scanQR, toNotifyWith: [.dismiss]) {
            
            $0.scanQR?.event(.cancel)
        }
    }
    
    // MARK: - templates
    
    func test_templates_shouldDeliverTemplates() {
        
        expect(.templates, toDeliver: .templates)
    }
    
    func test_templates_shouldNotifyWithDismissOnDismissAction() {
        
        expect(.templates, toNotifyWith: [.dismiss]) {
            
            $0.templates?.state.content.dismissAction()
        }
    }
    
    func test_templates_shouldNotifyWithMainTabOnMainTabStatus() {
        
        expect(.templates, toNotifyWith: [.select(.outside(.tab(.main)))]) {
            
            $0.templates?.event(.flow(.init(status: .tab(.main))))
        }
    }
    
    func test_templates_shouldNotifyWithPaymentsTabOnPaymentsTabStatus() {
        
        expect(
            .templates,
            toNotifyWith: [.select(.outside(.tab(.payments)))]
        ) {
            $0.templates?.event(.flow(.init(status: .tab(.payments))))
        }
    }
    
    func test_templates_shouldNotifyWithProductIDOnProductIDStatus() {
        
        let productID = makeProductID()
        
        expect(
            .templates,
            toNotifyWith: [.select(.outside(.productProfile(productID)))]
        ) {
            $0.templates?.event(.select(.productID(productID)))
        }
    }
    
    // MARK: - Helpers
    
    private typealias NotifyEvent = RootViewDomain.FlowDomain.NotifyEvent
    private typealias NotifySpy = CallSpy<NotifyEvent, Void>
    
    private func makeProductID() -> ProductData.ID {
        
        return .random(in: 0..<Int.max)
    }
    
    private func equatable(
        _ navigation: RootViewNavigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .outside(outside):
            return .outside(outside)
            
        case .scanQR:
            return .scanQR
            
        case .templates:
            return .templates
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case outside(RootViewOutside)
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
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ select: RootViewSelect,
        toNotifyWith expectedNotifyEvents: [NotifyEvent],
        on assert: @escaping (RootViewNavigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT().sut
        let notifySpy = NotifySpy(stubs: [()])
        let exp = expectation(description: "wait for completion")
        
        sut.getRootNavigation(
            select: select,
            notify: notifySpy.call
        ) {
            assert($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(notifySpy.payloads, expectedNotifyEvents, "Expected \(expectedNotifyEvents), but got \(notifySpy.payloads) instead.", file: file, line: line)
    }
}

// MARK: - DSL

extension RootViewNavigation {
    
    var scanQR: QRScannerModel? {
        
        guard case let .scanQR(node) = self else { return nil }
        return node.model.content
    }
    
    var templates: TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>? {
        
        guard case let .templates(node) = self else { return nil }
        return node.model
    }
}
