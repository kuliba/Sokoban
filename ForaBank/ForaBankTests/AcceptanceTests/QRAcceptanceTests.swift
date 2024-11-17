//
//  QRAcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import ViewInspector
import XCTest

final class QRAcceptanceTests: XCTestCase {
    
    func test_openQRWithFlowEvent_shouldOpenQRScreenCover() throws {
        
        let app = TestApp()
        try app.launch()
        
        try app.openQRWithFlowEvent()
        
        try XCTAssertNoThrow(app.qrFullScreenCover())
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
    
    private struct TestApp {
        
        private let window = UIWindow()
        private let factory: ModelRootFactory
        private let binder: RootViewDomain.Binder
        private let rootViewFactory: RootViewFactory
        
        private func root() throws -> RootViewHostingViewController {
            
            try XCTUnwrap(window.rootViewController as? RootViewHostingViewController)
        }
        
        init(
            featureFlags: FeatureFlags = .active,
            dismiss: @escaping () -> Void = {}
        ) {
            self.factory = .immediateEmpty()
            self.binder = factory.makeBinder(
                featureFlags: featureFlags,
                dismiss: dismiss
            )
            self.rootViewFactory = factory.makeRootViewFactory(
                featureFlags: .active
            )
        }
        
        func launch() throws {
            
            let rootViewController = RootViewHostingViewController(
                with: binder,
                rootViewFactory: rootViewFactory
            )
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
            
            _ = try root()
        }
        
        func openQRWithFlowEvent(
            timeout: TimeInterval = 0.5,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            binder.flow.event(.select(.scanQR))
            
            wait(timeout: timeout)
            
            switch binder.flow.state.navigation {
            case .scanQR:
                break
                
            default:
                XCTFail("Expected Scan QR", file: file, line: line)
            }
        }
        
        func qrFullScreenCover(
            timeout: TimeInterval = 0.1,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            wait(timeout: timeout)
            
            _ = try root().rootView.qrFullScreenCover()
            
            switch binder.flow.state.navigation {
            case .scanQR:
                break
                
            default:
                XCTFail("Expected Scan QR", file: file, line: line)
            }
        }
        
        func qrLegacyFullScreenCover(
            timeout: TimeInterval = 0.1,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            wait(timeout: timeout)
            
            _ = try root().rootView.qrLegacyFullScreenCover()
        }
        
        func tapMainViewQRButton(
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            try root().rootView.tapMainViewQRButton()
        }
        
        private func wait(timeout: TimeInterval = 0.1) {
            
            _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
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
