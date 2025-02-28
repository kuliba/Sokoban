//
//  FeatureFlagsLoaderTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.06.2024.
//

@testable import Vortex
import XCTest

final class FeatureFlagsLoaderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        var retrieveCalls = 0
        let sut = makeSUT { _ in retrieveCalls += 1; return "" }
        
        XCTAssertEqual(retrieveCalls, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - C2G
    
    func test_load_shouldDeliverActiveC2GForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .c2gFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            c2gFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveC2GForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            c2gFlag: .inactive
        ))
    }
    
    // MARK: - СreditCardMVP
    
    func test_load_shouldDeliverActiveСreditCardMVPForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .creditCardMVPFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            creditCardMVPFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveСreditCardMVPForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            creditCardMVPFlag: .inactive
        ))
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
    
    //MARK: OrderCardFlag
    
    func test_load_shouldDeliverActiveOrderCardFlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .orderCardFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            orderCardFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveOrderCardFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            orderCardFlag: .inactive
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
    
    // MARK: - SplashScreenFlag
    
    func test_load_shouldDeliverActiveSplashScreenFlagForActiveRetrieveResult() {
        
        let sut = makeSUT { $0 == .splashScreenFlag ? "1" : nil }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            splashScreenFlag: .active
        ))
    }
    
    func test_load_shouldDeliverInactiveSplashScreenFlagForInactiveRetrieveResult() {
        
        let sut = makeSUT { _ in "0" }
        
        let flags = sut.load()
        
        XCTAssertNoDiff(flags, makeFeatureFlags(
            splashScreenFlag: .inactive
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
        c2gFlag: C2GFlag? = nil,
        creditCardMVPFlag: СreditCardMVPFlag? = nil,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag? = nil,
        paymentsTransfersFlag: PaymentsTransfersFlag? = nil,
        savingsAccountFlag: SavingsAccountFlag? = nil,
        collateralLoanLandingFlag: CollateralLoanLandingFlag? = nil,
        splashScreenFlag: SplashScreenFlag? = nil,
        orderCardFlag: OrderCardFlag? = nil
    ) -> FeatureFlags {
        
        return .init(
            c2gFlag: c2gFlag?.map { $0 } ?? .inactive,
            creditCardMVPFlag: creditCardMVPFlag.map { $0 } ?? .inactive,
            getProductListByTypeV6Flag: getProductListByTypeV6Flag?.map { $0 } ?? .inactive,
            paymentsTransfersFlag: paymentsTransfersFlag?.map { $0 } ?? .inactive,
            savingsAccountFlag: savingsAccountFlag?.map { $0 } ?? .inactive,
            collateralLoanLandingFlag: collateralLoanLandingFlag?.map { $0 } ?? .inactive,
            splashScreenFlag: splashScreenFlag?.map { $0 } ?? .inactive,
            orderCardFlag: orderCardFlag?.map { $0 } ?? .inactive
        )
    }
}
