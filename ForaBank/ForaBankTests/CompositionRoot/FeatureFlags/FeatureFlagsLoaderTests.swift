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
    
    // MARK: - PaymentsTransfersFlag
    
    func test_load_shouldDeliverInactivePaymentsTransfersFlagForRetrieveFailure() {
        
        let sut = makeSUT { _ in nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            paymentsTransfersFlag: .init(.inactive)
        ))
    }
    
    func test_load_shouldDeliverInactivePaymentsTransfersFlagForUnknownRetrieveResult() {
        
        let sut = makeSUT { _ in "junk" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            paymentsTransfersFlag: .init(.inactive)
        ))
    }
    
    func test_load_shouldDeliverActiveLivePaymentsTransfersFlagForActiveLiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .paymentsTransfersFlag ? "1" : "junk" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            paymentsTransfersFlag: .init(.active)
        ))
    }
    
    // MARK: - ChangeSVCardLimitsFlag
    
    func test_load_shouldDeliverActiveChangeSVCardLimitsFlagForActiveRetrieveResult() {
        
        let sut = makeSUT {
            
            if case .changeSVCardLimitsFlag = $0 { return "1"}
            return nil
        }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            changeSVCardLimitsFlag: .init(.active)
        ))
    }
    
    func test_load_shouldDeliverInactiveChangeSVCardLimitsFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            changeSVCardLimitsFlag: .init(.inactive)
        ))
    }
    
    // MARK: - HistoryFilterFlag
    
    func test_load_shouldDeliverActiveHistoryFilterFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            historyFilterFlag: false
        ))
    }
    
    func test_load_shouldDeliverActiveHistoryFilterFlagForActiveRetrieveResult() {
        
        let sut = makeSUT {
            
            if case .historyFilterFlag = $0 { return "1"}
            return nil
        }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            historyFilterFlag: true
        ))
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
        historyFilterFlag: HistoryFilterFlag? = nil,
        changeSVCardLimitsFlag: ChangeSVCardLimitsFlag? = nil,
        paymentsTransfersFlag: PaymentsTransfersFlag? = nil,
        utilitiesPaymentsFlag: StubbedFeatureFlag? = nil
    ) -> FeatureFlags {
        
        return .init(
            changeSVCardLimitsFlag: changeSVCardLimitsFlag.map { .init($0.rawValue) } ?? .init(.inactive),
            historyFilterFlag: historyFilterFlag?.map { .init($0) } ?? .init(false),
            paymentsTransfersFlag: paymentsTransfersFlag.map { .init($0.rawValue) } ?? .init(.inactive),
            utilitiesPaymentsFlag: utilitiesPaymentsFlag.map { .init($0) } ?? .init(.inactive)
        )
    }
}
