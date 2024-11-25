//
//  AcceptanceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import PayHubUI
import XCTest

class AcceptanceTests: QRNavigationTests {
    
    func activePaymentsTransfersFlag() -> FeatureFlags {
        
        return .activeExcept(
            paymentsTransfersFlag: .active
        )
    }
    
    func inactivePaymentsTransfersFlag() -> FeatureFlags {
        
        return .activeExcept(
            paymentsTransfersFlag: .inactive
        )
    }
    
    struct TestApp {
        
        // TODO: - improve tests using SceneDelegate
        
        private let window = UIWindow()
        
        private let rootComposer: ModelRootComposer
        private let binder: ForaBank.RootViewDomain.Binder
        private let rootViewFactory: RootViewFactory
        
        private func root() throws -> RootViewHostingViewController {
            
            try XCTUnwrap(window.rootViewController as? RootViewHostingViewController)
        }
        
        init(
            featureFlags: FeatureFlags = .active,
            dismiss: @escaping () -> Void = {},
            scanResult: QRModelResult = .unknown,
            scanner: any QRScannerViewModel = QRScannerViewModelSpy(),
            schedulers: Schedulers = .immediate
        ) {
            self.rootComposer = .init(
                mapScanResult: { _, completion in completion(scanResult) },
                scanner: scanner,
                schedulers: schedulers
            )
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
