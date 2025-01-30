//
//  RootViewModelFactory+getCorporateTransfersNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getCorporateTransfersNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - meToMe
    
    func test_meToMe_shouldDeliverUserAccount() {
        
        expect(.meToMe, toDeliver: .meToMe)
    }
    
    // MARK: - openProduct
    
    func test_openProduct_shouldDeliverOpenProduct() {
        
        expect(.openProduct, toDeliver: .openProduct)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = Vortex.PaymentsTransfersCorporateTransfersDomain
    
    private func expect(
        sut: SUT? = nil,
        _ select: Domain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for get navigation completion")
        
        sut.getNavigation(
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .meToMe:
            return .meToMe
            
        case .openProduct:
            return .openProduct
        }
    }
    
    // TODO: improve, but need to control objects creation => SUT needs a dependency
    enum EquatableNavigation: Equatable {
        
        case meToMe
        case openProduct
    }
}
