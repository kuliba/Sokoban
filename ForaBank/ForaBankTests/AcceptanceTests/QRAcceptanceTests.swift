//
//  QRAcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import ViewInspector
import XCTest

final class QRAcceptanceTests: AcceptanceTests {
    
    func test_openQRWithFlowEvent_shouldOpenRootViewQRScannerFullScreenCover() throws {
        
        let app = TestApp()
        let rootView = try app.launch()
        
        openQRWithFlowEvent(app)
        
        expectRootViewQRScannerFullScreenCover(rootView)
        expectNoMainViewQRScannerFullScreenCover(rootView)
    }
    
    func test_tapMainViewQRButton_shouldOpenRootViewQRScannerFullScreenCoverOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .active
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        expectRootViewQRScannerFullScreenCover(rootView)
        expectNoMainViewQRScannerFullScreenCover(rootView)
    }
    
    func test_tapMainViewQRButton_shouldOpenMainViewQRScannerFullScreenCover() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .inactive
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        expectMainViewQRScannerFullScreenCover(rootView)
        expectNoRootViewQRScannerFullScreenCover(rootView)
    }
    
    // MARK: - Helpers
    
    private func openQRWithFlowEvent(
        _ app: TestApp,
        timeout: TimeInterval = 1
    ) {
        wait(timeout: timeout) {
            
            try app.openQRWithFlowEvent()
        }
    }
    
    private func tapMainViewQRButton(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1
    ) {
        wait(timeout: timeout) {
            
            try rootView.tapMainViewQRButton()
        }
    }
    
    func expectRootViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.rootViewQRScannerFullScreenCover(), "Expected Root View FullScreenCover with QRScanner", file: file, line: line)
    }
    
    func expectNoRootViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try rootView.rootViewQRScannerFullScreenCover(), "Expected No Root View FullScreenCover with QRScanner", file: file, line: line)
    }
    
    func expectMainViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.mainViewQRScannerFullScreenCover(), "Expected Main View FullScreenCover with QRScanner", file: file, line: line)
    }
    
    func expectNoMainViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try rootView.mainViewQRScannerFullScreenCover(), "Expected No Main View FullScreenCover with QRScanner", file: file, line: line)
    }
}

extension InspectableFullScreenCoverWithItem: ItemPopupPresenter { }

private extension RootViewBinderView {
    
    func rootViewQRScannerFullScreenCover(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try inspect()
            .find(RootView.self)
            .fullScreenCover()
            .find(viewWithAccessibilityIdentifier: ElementIDs.rootView(.qrFullScreenCover).rawValue)
    }
    
    func mainViewQRScannerFullScreenCover(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try inspect()
            .find(viewWithAccessibilityIdentifier: ElementIDs.mainView(.fullScreenCoverAnchor).rawValue)
            .fullScreenCover()
            .find(viewWithAccessibilityIdentifier: ElementIDs.mainView(.qrScanner).rawValue)
    }
    
    func tapMainViewQRButton() throws {
        
        _ = try inspect()
            .find(MainSectionFastOperationView.self)
            .find(button: FastOperationsTitles.qr)
            .tap()
    }
}
