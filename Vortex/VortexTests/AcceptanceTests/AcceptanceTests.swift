//
//  AcceptanceTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import Vortex
import PayHub
import ViewInspector
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
        private let binder: Vortex.RootViewDomain.Binder
        private let rootViewFactory: RootViewFactory
        
        private func root() throws -> RootViewHostingViewController {
            
            try XCTUnwrap(window.rootViewController as? RootViewHostingViewController)
        }
        
        init(
            featureFlags: FeatureFlags = .active,
            httpClient: any HTTPClient = HTTPClientSpy(),
            dismiss: @escaping () -> Void = {},
            model: Model = .mockWithEmptyExcept(),
            rootEvent: @escaping (RootViewSelect) -> Void = { _ in },
            scanResult: Vortex.QRModelResult = .unknown,
            scanner: any QRScannerViewModel = QRScannerViewModelSpy(),
            schedulers: Schedulers = .immediate
        ) {
            self.rootComposer = .init(
                httpClient: httpClient,
                mapScanResult: { _, completion in completion(scanResult) },
                model: model,
                scanner: scanner,
                schedulers: schedulers
            )
            self.binder = rootComposer.makeBinder(
                featureFlags: featureFlags,
                dismiss: dismiss
            )
            self.rootViewFactory = rootComposer.makeRootViewFactory(
                featureFlags: .active, 
                rootEvent: rootEvent
            )
        }
        
        func launch() throws -> RootBinderView {
            
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

extension RootBinderView {
    
    @available(iOS 16.0, *)
    func rootViewDestination(
        for id: ElementIDs.RootView.Destination
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try inspect()
            .find(RootView.self)
            .background().navigationLink() // we are using custom `View.navigationDestination(_:item:content:)
            .find(viewWithAccessibilityIdentifier: id.rawValue)
    }
}
