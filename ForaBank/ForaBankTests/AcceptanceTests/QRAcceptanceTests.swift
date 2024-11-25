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
        
        let app = TestApp(featureFlags: activePaymentsTransfersFlag())
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        expectRootViewQRScannerFullScreenCover(rootView)
        expectNoMainViewQRScannerFullScreenCover(rootView)
    }
    
    func test_tapMainViewQRButton_shouldOpenMainViewQRScannerFullScreenCoverOnInactiveFlag() throws {
        
        let app = TestApp(featureFlags: inactivePaymentsTransfersFlag())
        let rootView = try app.launch()
        
        tapMainViewQRButton(rootView)
        
        expectMainViewQRScannerFullScreenCover(rootView)
        expectNoRootViewQRScannerFullScreenCover(rootView)
    }
    
    func test_closeQRScanner_shouldCloseRootViewQRScannerFullScreenCoverOnActiveFlag() throws {
        
        let app = TestApp(featureFlags: activePaymentsTransfersFlag())
        let rootView = try app.launch()
        tapMainViewQRButton(rootView)
        expectRootViewQRScannerFullScreenCover(rootView)
        
        tapRootViewFullScreenCoverCloseQRButton(rootView)
        
        expectNoRootViewQRScannerFullScreenCover(rootView)
        expectNoMainViewQRScannerFullScreenCover(rootView)
    }
    
    // When a user successfully scans the c2bSubscribe QR code, a payment for the c2bSubscribe is presented
    @available(iOS 16.0, *)
    func test_shouldPresentPaymentOnSuccessfulC2BSubscribeQRScan() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .c2bSubscribeURL(anyURL()),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectPaymentPresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentPaymentOnSuccessfulC2BQRScan() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .c2bURL(anyURL()),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectPaymentPresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentQRFailureOnQRScanFailure() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .failure(anyQRCode()),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectQRFailurePresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentQRFailureOnMissingINN() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.missingINN(anyQRCode())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectQRFailurePresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentProviderPickerOnMixed() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.mixed(makeMixedQRResult())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)

        expectProviderPickerPresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentOperatorSearchOnMultiple() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.multiple(makeMultipleQRResult())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)

        expectOperatorSearchPresented(rootView)
    }
    
    @available(iOS 16.0, *)
    func test_shouldPresentPaymentOnQRScanNoneMapped() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.none(makeQR())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectPaymentPresented(rootView)
    }

    @available(iOS 16.0, *)
    func test_shouldPresentProviderServicePickerOnQRScanProvider() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.provider(makeProviderPayload())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectProviderServicePickerPresented(rootView)
    }

    @available(iOS 16.0, *)
    func test_shouldPresentOperatorViewOnQRScanSingle() throws {
        
        let scanner = QRScannerViewModelSpy()
        let app = TestApp(
            scanResult: .mapped(.single(makeSinglePayload())),
            scanner: scanner
        )
        let rootView = try app.launch()
        
        scanSuccessfully(rootView, scanner)
        
        expectOperatorViewPresented(rootView)
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
    
    private func scanSuccessfully(
        _ rootView: RootViewBinderView,
        _ scanner: QRScannerViewModelSpy,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        tapMainViewQRButton(rootView, file: file, line: line)
        
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            scanner.complete(with: .success(anyMessage()))
        }
    }
    
    private func scanWithFailure(
        _ rootView: RootViewBinderView,
        _ scanner: QRScannerViewModelSpy,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        tapMainViewQRButton(rootView, file: file, line: line)
        
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            scanner.complete(with: .failure(.unableCreateVideoInput))
        }
    }
    
    @available(iOS 16.0, *)
    private func expectPaymentPresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .payments), "Expected Root View FullScreenCover Destination with Payment.", file: file, line: line)
        }
    }
    
    @available(iOS 16.0, *)
    private func expectQRFailurePresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .qrFailure), "Expected Root View FullScreenCover Destination with QR Failure.", file: file, line: line)
        }
    }
    
    @available(iOS 16.0, *)
    private func expectProviderPickerPresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .providerPicker), "Expected Root View FullScreenCover Destination with QR Failure.", file: file, line: line)
        }
    }
    
    @available(iOS 16.0, *)
    private func expectOperatorSearchPresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .operatorSearch), "Expected Root View FullScreenCover Destination with QR Failure.", file: file, line: line)
        }
    }
    
    @available(iOS 16.0, *)
    private func expectProviderServicePickerPresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .providerServicePicker), "Expected Root View FullScreenCover Destination with ProviderServicePicker.", file: file, line: line)
        }
    }
    
    @available(iOS 16.0, *)
    private func expectOperatorViewPresented(
        _ rootView: RootViewBinderView,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            timeout: timeout,
            file: file, line: line
        ) {
            XCTAssertNoThrow(try rootView.rootViewQRScannerDestination(for: .operatorView), "Expected Root View FullScreenCover Destination with OperatorView.", file: file, line: line)
        }
    }
    
    private func expectRootViewQRScannerFullScreenCover(
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
    
    @available(iOS 16.0, *)
    func rootViewQRScannerDestination(
    ) throws -> InspectableView<ViewType.NavigationLink> {
        
        try rootViewQRScannerFullScreenCover()
            .find(viewWithAccessibilityIdentifier: ElementIDs.qrScanner.rawValue)
            .background().navigationLink() // we are using custom `View.navigationDestination(_:item:content:)
    }
    
    @available(iOS 16.0, *)
    func rootViewQRScannerDestination(
        for id: ElementIDs
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        
        try rootViewQRScannerDestination()
            .find(viewWithAccessibilityIdentifier: id.rawValue)
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
