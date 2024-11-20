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
    
    // TODO: - scan QR can be initiated from the main view, payments view, or toolbar
    
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
    
    func test_closeQRScanner_shouldCloseRootViewQRScannerFullScreenCoverOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .active
        ))
        let rootView = try app.launch()
        tapMainViewQRButton(rootView)
        expectRootViewQRScannerFullScreenCover(rootView)
        
        tapRootViewFullScreenCoverCloseQRButton(rootView)
        
        expectNoRootViewQRScannerFullScreenCover(rootView)
        expectNoMainViewQRScannerFullScreenCover(rootView)
    }
    
    // MARK: - Helpers
    
    private func openQRWithFlowEvent(
        _ app: TestApp,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) { try app.openQRWithFlowEvent() }
    }
    
    private func tapMainViewQRButton(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) { try rootView.tapMainViewQRButton() }
    }
    
    private func tapRootViewFullScreenCoverCloseQRButton(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            do {
                try rootView.tapRootViewFullScreenCoverCloseQRButton()
            } catch {
                XCTFail("Expected Close QRScanner Button on Root View FullScreenCover, but \(error)", file: file, line: line)
            }
        }
    }
    
    func expectRootViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.rootViewQRScannerFullScreenCover(), "Expected Root View FullScreenCover with QRScanner.", file: file, line: line)
    }
    
    private func expectNoRootViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try rootView.rootViewQRScannerFullScreenCover(), "Expected No Root View FullScreenCover with QRScanner, but there is one.", file: file, line: line)
    }
    
    private func expectMainViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try rootView.mainViewQRScannerFullScreenCover(), "Expected Main View FullScreenCover with QRScanner.", file: file, line: line)
    }
    
    private func expectNoMainViewQRScannerFullScreenCover(
        _ rootView: RootViewBinderView,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try rootView.mainViewQRScannerFullScreenCover(), "Expected No Main View FullScreenCover with QRScanner, but there is one.", file: file, line: line)
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
    
    func tapRootViewFullScreenCoverCloseQRButton() throws {
        
        try rootViewQRScannerFullScreenCover()
            .find(viewWithAccessibilityIdentifier: ElementIDs.fullScreenCover(.closeButton).rawValue)
            .find(button: "Отмена")
            .tap()
    }
}
