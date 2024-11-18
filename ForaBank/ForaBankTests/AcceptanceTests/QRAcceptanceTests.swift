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
    
    // TODO: - fix flaky tests
    
    //    func test_tapMainViewQRButton_shouldOpenQRScreenCover() throws {
    //
    //        let app = TestApp()
    //        try app.launch()
    //
    //        try app.tapMainViewQRButton()
    //
    //        try XCTAssertNoThrow(app.qrFullScreenCover())
    //    }
    //
    //    func test_tapMainViewQRButton_shouldOpenLegacyQRScreenCover() throws {
    //
    //        let app = TestApp()
    //        try app.launch()
    //
    //        try app.tapMainViewQRButton()
    //
    //        try XCTAssertNoThrow(app.qrLegacyFullScreenCover(timeout: 1))
    //    }
    
    // MARK: - Helpers
    
    private func openQRWithFlowEvent(
        _ app: TestApp,
        timeout: TimeInterval = 1
    ) {
        wait(timeout: timeout) {
            
            try app.openQRWithFlowEvent()
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
