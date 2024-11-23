//
//  TemplatesAcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.11.2024.
//

@testable import ForaBank
import ViewInspector
import XCTest

final class TemplatesAcceptanceTests: AcceptanceTests {
    
    @available(iOS 16.0, *)
    func test_shouldPresentTemplatesOnMainViewTemplatesButtonTapOnInactiveFlag() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .inactive
        ))
        let rootView = try app.launch()
        
        tapMainViewTemplatesButton(rootView)
        
        expectTemplatesPresentedOnMainView(rootView)
    }
    
    // MARK: - Helpers
    
    func tapMainViewTemplatesButton(
        _ rootView: RootViewBinderView,
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
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.mainViewTemplatesDestination(), "Expected Main View Destination with Templates.", file: file, line: line)
    }
}

private extension RootViewBinderView {
    
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
}
