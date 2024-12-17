//
//  StandardPaymentAcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.11.2024.
//

@testable import ForaBank
import ViewInspector
import XCTest

final class StandardPaymentAcceptanceTests: AcceptanceTests {
    
    @available(iOS 16.0, *)
    func test_shouldPresentStandardPaymentOnMainViewUtilityPaymentButtonTap() throws {
        
        let httpClient = HTTPClientSpy()
        let app = try TestApp(
            httpClient: httpClient,
            model: .withServiceCategoryAndOperator()
        )
        let rootView = try app.launch()
        
        tapMainViewUtilityPaymentButton(rootView)
        
        completeGetAllLatestPayments(httpClient)
        
        expectStandardPaymentPresentedOnRootView(rootView)
    }
    
    // MARK: - Helpers
    
    private func tapMainViewUtilityPaymentButton(
        _ rootView: RootBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) { try rootView.tapMainViewUtilityPaymentButton() }
    }
    
    private func completeGetAllLatestPayments(
        _ httpClient: HTTPClientSpy,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(httpClient.requests.map(\.url?.lastPathComponent), [
            "getAllLatestPayments"
        ], file: file, line: line)
        
        httpClient.complete(with: anyError())
    }
    
    @available(iOS 16.0, *)
    private func expectStandardPaymentPresentedOnRootView(
        _ rootView: RootBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.rootViewStandardPaymentDestination(), "Expected Root View Destination with StandardPayment.", file: file, line: line)
    }
}

private extension RootBinderView {
    
    func tapMainViewUtilityPaymentButton() throws {
        
        _ = try inspect()
            .find(MainSectionFastOperationView.self)
            .find(button: FastOperationsTitles.utilityPayment)
            .tap()
    }
    
    @available(iOS 16.0, *)
    func rootViewStandardPaymentDestination(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try rootViewDestination(for: .standardPayment)
    }
}
