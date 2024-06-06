//
//  FeatureFlagsLoaderTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.06.2024.
//

@testable import ForaBank
import XCTest

final class FeatureFlagsLoaderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        var retrieveCalls = 0
        let sut = makeSUT { _ in retrieveCalls += 1; return "" }
        
        XCTAssertEqual(retrieveCalls, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - UtilitiesPaymentsFlag
    
    func test_load_shouldDeliverInactiveUtilitiesPaymentsFlagForRetrieveFailure() {
        
        let sut = makeSUT { _ in nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            utilitiesPaymentsFlag: .inactive
        ))
    }
    
    func test_load_shouldDeliverInactiveUtilitiesPaymentsFlagForUnknownRetrieveResult() {
        
        let sut = makeSUT { _ in "junk" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            utilitiesPaymentsFlag: .inactive
        ))
    }
    
    func test_load_shouldDeliverActiveLiveUtilitiesPaymentsFlagForActiveLiveRetrieveResult() {
        
        let sut = makeSUT { _ in "sber_providers_live" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            utilitiesPaymentsFlag: .active(.live)
        ))
    }
    
    func test_load_shouldDeliverActiveStubUtilitiesPaymentsFlagForActiveStubRetrieveResult() {
        
        let sut = makeSUT { _ in "sber_providers_stub" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            utilitiesPaymentsFlag: .active(.stub)
        ))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FeatureFlagsLoader
    
    private func makeSUT(
        retrieve: @escaping SUT.Retrieve,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(retrieve: retrieve)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeFeatureFlags(
        utilitiesPaymentsFlag: StubbedFeatureFlag? = nil
    ) -> FeatureFlags {
        
        return .init(
            utilitiesPaymentsFlag: utilitiesPaymentsFlag.map { .init($0) } ?? .init(.inactive)
        )
    }
}
