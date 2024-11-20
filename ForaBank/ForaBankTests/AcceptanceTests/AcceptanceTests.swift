//
//  AcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import XCTest

class AcceptanceTests: XCTestCase {
    
    struct TestApp {
        
        private let window = UIWindow()
        
        private let rootComposer: ModelRootComposer
        private let binder: RootViewDomain.Binder
        private let rootViewFactory: RootViewFactory
        
        private func root() throws -> RootViewHostingViewController {
            
            try XCTUnwrap(window.rootViewController as? RootViewHostingViewController)
        }
        
        init(
            featureFlags: FeatureFlags = .active,
            dismiss: @escaping () -> Void = {}
        ) {
            self.rootComposer = .init(schedulers: .immediate)
            self.binder = rootComposer.makeBinder(
                featureFlags: featureFlags,
                dismiss: dismiss
            )
            self.rootViewFactory = rootComposer.makeRootViewFactory(
                featureFlags: .active
            )
        }
        
        func launch() throws -> RootViewBinderView {
            
            let rootViewController = RootViewHostingViewController(
                with: binder,
                rootViewFactory: rootViewFactory
            )
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
            
            return try root().rootView
        }
        
        func openQRWithFlowEvent(
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            
            binder.flow.event(.select(.scanQR))
            
            switch binder.flow.state.navigation {
            case .scanQR:
                break
                
            default:
                XCTFail("Expected Scan QR", file: file, line: line)
            }
        }
    }
}
