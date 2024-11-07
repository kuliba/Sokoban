//
//  ContentViewModelComposerTests.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 05.11.2024.
//

import ForaTools
import PayHubUI
@testable import QRNavigationPreview
import XCTest

final class ContentViewModelComposerTests: XCTestCase {
    
    // MARK: - scanQR
    
    func test_scanQR_shouldSetNavigationOnSelect() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        
        XCTAssertNoDiff(equatable(flow.state), .init(navigation: .qr))
    }
    
    func test_scanQR_shouldResetNavigationOnDismiss() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        XCTAssertNotNil(flow.state.navigation)
        
        flow.event(.dismiss)
        
        XCTAssertNil(flow.state.navigation)
    }
    
    func test_scanQR_shouldResetNavigationOnQRClose() throws {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        XCTAssertNotNil(flow.state.navigation)
        
        try flow.qr.close()
        
        XCTAssertNil(flow.state.navigation)
    }
    
    // MARK: - c2bSubscribeURL
    
    func test_shouldSetQRNavigationOnC2BSubscribe() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try XCTAssertNil(flow.qrFlow.state.navigation)
        
        try flow.qr.emit(.c2bSubscribeURL(anyURL()))
        
        try XCTAssertNotNil(flow.qrFlow.state.navigation)
    }
    
    func test_shouldResetQRNavigationOnC2BSubscribeClose() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try flow.qr.emit(.c2bSubscribeURL(anyURL()))
        XCTAssertNotNil(flow.qrNavigation)
        
        try flow.payments.close()
        
        XCTAssertNil(flow.qrNavigation)
    }
    
    func test_shouldResetQRNavigationOnC2BSubscribeScanQR() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try flow.qr.emit(.c2bSubscribeURL(anyURL()))
        XCTAssertNotNil(flow.qrNavigation)
        
        try flow.payments.scanQR()
        
        XCTAssertNil(flow.qrNavigation)
    }
    
    // MARK: - c2bURL
    
    func test_shouldSetQRNavigationOnC2B() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try XCTAssertNil(flow.qrFlow.state.navigation)
        
        try flow.qr.emit(.c2bURL(anyURL()))
        
        try XCTAssertNotNil(flow.qrFlow.state.navigation)
    }
    
    func test_shouldResetQRNavigationOnC2BClose() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try flow.qr.emit(.c2bURL(anyURL()))
        XCTAssertNotNil(flow.qrNavigation)
        
        try flow.payments.close()
        
        XCTAssertNil(flow.qrNavigation)
    }
    
    func test_shouldResetQRNavigationOnC2BScanQR() throws {
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try flow.qr.emit(.c2bURL(anyURL()))
        XCTAssertNotNil(flow.qrNavigation)
        
        try flow.payments.scanQR()
        
        XCTAssertNil(flow.qrNavigation)
    }
    
    // MARK: - failure
    
    func test_shouldSetQRNavigationOnFailure() throws {
        
        let qrCode = makeQRCode()
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        try XCTAssertNil(flow.qrFlow.state.navigation)
        
        try flow.qr.emit(.failure(qrCode))
        
        try XCTAssertNotNil(flow.qrFlow.state.navigation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentViewModelComposer
    private typealias State = ContentViewDomain.State
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            mainScheduler: .immediate,
            interactiveScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func equatable(_ state: State) -> EquatableState {
        
        switch state.navigation {
        case .none:
            return .init(isLoading: state.isLoading, navigation: .none)
            
        case .qr:
            return .init(isLoading: state.isLoading, navigation: .qr)
        }
    }
    
    private struct EquatableState: Equatable {
        
        var isLoading = false
        let navigation: EquatableNavigation?
        
        enum EquatableNavigation: Equatable {
            
            case qr
        }
    }
    
    private func makeQRCode(
        value: String = anyMessage()
    ) -> QRCode {
        
        return .init(value: value)
    }
}

// MARK: - DSL

private extension ContentViewDomain.Flow {
    
    var payments: Payments {
        
        get throws {
            
            guard case let .payments(node) = try qrFlow.state.navigation
            else { throw NSError(domain: "Expected Payments", code: -1)}
            
            return node.model
        }
    }
    
    var qrNavigation: QRNavigationPreview.QRNavigation? {
        
        try? qrFlow.state.navigation
    }
    
    var qr: QRModel {
        
        get throws { try qrNode.model.content }
    }
    
    var qrFlow: QRNavigationPreview.QRDomain.Flow {
        
        get throws { try qrNode.model.flow }
    }
    
    private var qrNode: PayHubUI.Node<QRNavigationPreview.QRDomain.Binder> {
        
        get throws {
            
            guard case let .qr(node) = state.navigation
            else { throw NSError(domain: "Expected QR, but got \(String(describing: state.navigation)).", code: -1) }
            
            return node
        }
    }
}
