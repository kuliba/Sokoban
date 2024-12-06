//
//  TemplatesAcceptanceTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 23.11.2024.
//

@testable import ForaBank
import ViewInspector
import XCTest

final class TemplatesAcceptanceTests: AcceptanceTests {
    
    @available(iOS 16.0, *)
    func test_shouldPresentMainViewTemplatesOnMainViewTemplatesButtonTapOnInactiveFlag() throws {
        
        let app = TestApp(featureFlags: inactivePaymentsTransfersFlag())
        let rootView = try app.launch()
        
        tapMainViewTemplatesButton(rootView)
        
        expectTemplatesPresentedOnMainView(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentRootViewTemplatesOnMainViewTemplatesButtonTapOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: activePaymentsTransfersFlag())
        let rootView = try app.launch()
        
        tapMainViewTemplatesButton(rootView)
        
        expectTemplatesPresentedOnRootView(rootView)
    }
    
#warning("add similar tests for Payments tab")
    
    // MARK: - Helpers
    
    func tapMainViewTemplatesButton(
        _ rootView: RootBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) { try rootView.tapMainViewTemplatesButton() }
    }
    
    @available(iOS 16.0, *)
    func expectTemplatesPresentedOnMainView(
        _ rootView: RootBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.mainViewTemplatesDestination(), "Expected Main View Destination with Templates.", file: file, line: line)
    }
    
    @available(iOS 16.0, *)
    func expectTemplatesPresentedOnRootView(
        _ rootView: RootBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.rootViewTemplatesDestination(), "Expected Root View Destination with Templates.", file: file, line: line)
    }
}

private extension RootBinderView {
    
    func tapMainViewTemplatesButton() throws {
        
        _ = try inspect()
            .find(MainSectionFastOperationView.self)
            .find(button: FastOperationsTitles.templates)
            .tap()
    }
    
    @available(iOS 16.0, *)
    func mainViewTemplatesDestination(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try inspect()
            .find(RootView.self)
            .find(viewWithAccessibilityIdentifier: ElementIDs.mainView(.content).rawValue)
            .background().navigationLink() // we are using custom `View.navigationDestination(_:item:content:)
            .find(viewWithAccessibilityIdentifier: ElementIDs.mainView(.templates).rawValue)
    }
    
    @available(iOS 16.0, *)
    func rootViewTemplatesDestination(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try rootViewDestination(for: .templates)
    }
}
