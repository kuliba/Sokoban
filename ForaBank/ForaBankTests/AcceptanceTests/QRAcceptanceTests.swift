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
    
    func test_openQR_shouldOpenQRScreenCover() throws {
        
        let app = TestApp()
        try app.launch()
        
        try app.openQR()
        
        try XCTAssertNoThrow(app.qrFullScreenCover())
    }
    
    // MARK: - Helpers
    
    private struct TestApp {
        
        private let window = UIWindow()
        private let factory: ModelRootFactory
        private let binder: RootViewDomain.Binder
        private let rootViewFactory: RootViewFactory
        
        private func root() throws -> RootViewHostingViewController {
            
            try XCTUnwrap(window.rootViewController as? RootViewHostingViewController)
        }
        
        init() {
            
            self.factory = .immediateEmpty()
            self.binder = factory.makeBinder(featureFlags: .active, dismiss: {})
            self.rootViewFactory = factory.makeRootViewFactory(featureFlags: .active)
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
        
        func openQR(
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            binder.flow.event(.select(.scanQR))
            
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
            
            switch binder.flow.state.navigation {
            case .scanQR:
                break
                
            default:
                XCTFail("Expected Scan QR", file: file, line: line)
            }
        }
        
        func qrFullScreenCover() throws {
            
            _ = try root().rootView.qrFullScreenCover()
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
            .find(viewWithAccessibilityIdentifier: RootWrapperView.ElementIDs.qrFullScreenCover.rawValue)
    }
}
