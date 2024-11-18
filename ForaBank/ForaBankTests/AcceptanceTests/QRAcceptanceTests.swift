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
    
    func test_openQRWithFlowEvent_shouldOpenQRScreenCover() throws {
        
        let app = TestApp()
        let rootView = try app.launch()
        
        openQRWithFlowEvent(app)
        
        try XCTAssertNoThrow(rootView.qrFullScreenCover())
    }
    
    func test_tapMainViewQRButton_shouldOpenQRScreenCoverOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .active
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        try XCTAssertNoThrow(rootView.qrFullScreenCover())
    }
    
    func test_tapMainViewQRButton_shouldOpenLegacyQRScreenCover() throws {
        
        let app = TestApp(featureFlags: .activeExcept(
            paymentsTransfersFlag: .inactive
        ))
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        try XCTAssertNoThrow(rootView.qrLegacyFullScreenCover())
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
    
    func qrFullScreenCover(
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try inspect()
            .find(RootView.self)
            .fullScreenCover()
            .find(viewWithAccessibilityIdentifier: ElementIDs.rootView(.qrFullScreenCover).rawValue)
    }
    
    func qrLegacyFullScreenCover(
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
