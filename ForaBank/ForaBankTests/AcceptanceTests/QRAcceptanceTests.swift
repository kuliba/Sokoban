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
        
        try XCTAssertNoThrow(rootView.rootViewQRScannerFullScreenCover())
        try XCTAssertThrowsError(rootView.mainViewQRScannerFullScreenCover())
    }
    
    func test_tapMainViewQRButton_shouldOpenRootViewQRScannerFullScreenCoverOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .active
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        try XCTAssertNoThrow(rootView.rootViewQRScannerFullScreenCover())
        try XCTAssertThrowsError(rootView.mainViewQRScannerFullScreenCover())
    }
    
    func test_tapMainViewQRButton_shouldOpenMainViewQRScannerFullScreenCover() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .inactive
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        try XCTAssertNoThrow(rootView.mainViewQRScannerFullScreenCover())
        try XCTAssertThrowsError(rootView.rootViewQRScannerFullScreenCover())
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
