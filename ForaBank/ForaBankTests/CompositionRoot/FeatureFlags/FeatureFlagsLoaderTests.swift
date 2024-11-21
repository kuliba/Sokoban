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
            paymentsTransfersFlag: .inactive
        ))
    }
    
    func test_load_shouldDeliverInactivePaymentsTransfersFlagForUnknownRetrieveResult() {
        
        let sut = makeSUT { _ in "junk" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            paymentsTransfersFlag: .inactive
        ))
    }
    
    func test_load_shouldDeliverActiveLivePaymentsTransfersFlagForActiveLiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .paymentsTransfersFlag ? "1" : "junk" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            paymentsTransfersFlag: .active
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
            changeSVCardLimitsFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveChangeSVCardLimitsFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            changeSVCardLimitsFlag: .inactive
        ))
    }
    
    // MARK: - GetProductListByTypeV6Flag
    
    func test_load_shouldDeliverActiveGetProductListByTypeV6FlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .getProductListByTypeV6Flag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            getProductListByTypeV6Flag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveGetProductListByTypeV6FlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            getProductListByTypeV6Flag: .inactive
        ))
    }
    
    // MARK: - MarketplaceFlag
    
    func test_load_shouldDeliverActiveMarketplaceFlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .marketplaceFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            marketplaceFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveMarketplaceFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            marketplaceFlag: .inactive
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
    
    // MARK: - CollateralLoanLandingFlag
    
    func test_load_shouldDeliverActiveCollateralLoanLandingFlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .collateralLoanLandingFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            collateralLoanLandingFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveCollateralLoanLandingFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            collateralLoanLandingFlag: .inactive
        ))
    }
    
    // MARK: - SavingsAccountFlag
    
    func test_load_shouldDeliverActiveSavingsAccountFlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .savingsAccountFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            savingsAccountFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveSavingsAccountFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            savingsAccountFlag: .inactive
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
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag? = nil,
        marketplaceFlag: MarketplaceFlag? = nil,
        paymentsTransfersFlag: PaymentsTransfersFlag? = nil,
        savingsAccountFlag: SavingsAccountFlag? = nil,
        collateralLoanLandingFlag: CollateralLoanLandingFlag? = nil
    ) -> FeatureFlags {
        
        .init(
            changeSVCardLimitsFlag: changeSVCardLimitsFlag?.map { $0 } ?? .inactive,
            getProductListByTypeV6Flag: getProductListByTypeV6Flag?.map { $0 } ?? .inactive,
            marketplaceFlag: marketplaceFlag?.map { $0 } ?? .inactive,
            historyFilterFlag: historyFilterFlag?.map { $0 } ?? .init(false),
            paymentsTransfersFlag: paymentsTransfersFlag?.map { $0 } ?? .inactive,
            savingsAccountFlag: savingsAccountFlag?.map { $0 } ?? .inactive,
            collateralLoanLandingFlag: collateralLoanLandingFlag?.map { $0 } ?? .inactive
        )
    }
}
