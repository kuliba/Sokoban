//
//  QRNavigationPreviewTests.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 05.11.2024.
//

@testable import QRNavigationPreview
import XCTest

final class QRNavigationPreviewTests: XCTestCase {
    
    func test_shouldSetNavigationOnSelect() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        
        XCTAssertNoDiff(equatable(flow.state), .init(navigation: .qr))
    }
    
    func test_shouldResetNavigationOnDismiss() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        XCTAssertNotNil(flow.state.navigation)
        
        flow.event(.dismiss)
        
        XCTAssertNil(flow.state.navigation)
    }
    
    func test_shouldResetNavigationOnQRClose() throws{
        
        let flow = makeSUT().compose()
        flow.event(.select(.scanQR))
        XCTAssertNotNil(flow.state.navigation)

        try flow.qr.close()
        
        XCTAssertNil(flow.state.navigation)
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
}

// MARK: - DSL

private extension ContentViewDomain.Flow {
    
    var qr: QRModel {
        
        get throws {
            
            guard case let .qr(node) = state.navigation 
            else { throw NSError(domain: "Expected QR, but got \(String(describing: state.navigation)).", code: -1) }
            
            return node.model.content
        }
    }
}
