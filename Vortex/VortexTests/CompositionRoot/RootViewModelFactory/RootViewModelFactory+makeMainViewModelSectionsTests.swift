//
//  RootViewModelFactory+makeMainViewModelSectionsTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 20.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeMainViewModelSectionsTests: RootViewModelFactoryTests {
    
    func test_shouldMakeMainViewModelSections() {
        
        let (sut, _, _) = makeSUT()
        let bannersBinder = BannersBinder.immediate
        
        let sections = sut.makeMainViewModelSections(
            bannersBinder: bannersBinder,
            c2gFlag: .inactive,
            collateralLoanLandingFlag: .active,
            savingsAccountFlag: .inactive
        )
        
        XCTAssertTrue(sections.count == 6)
        XCTAssertTrue(sections[0] is MainSectionProductsView.ViewModel)
        XCTAssertTrue(sections[1] is MainSectionFastOperationView.ViewModel)
        XCTAssertTrue(sections[2] is MainSectionPromoView.ViewModel)
        XCTAssertTrue(sections[3] is MainSectionCurrencyMetallView.ViewModel)
        XCTAssertTrue(sections[4] is MainSectionOpenProductView.ViewModel)
        XCTAssertTrue(sections[5] is MainSectionAtmView.ViewModel)
    }
    
    // MARK: - FastOperation
    
    func test_shouldMakeFastOperationSection_onInactiveC2GFlag() {
        
        let sections = makeMainViewModelSections(c2gFlag: .inactive)
        
        XCTAssertEqual(sections.fastOperationSections.count, 1)
    }
    
    func test_shouldMakeFastOperationSection_onActiveC2GFlag() {
        
        let sections = makeMainViewModelSections(c2gFlag: .active)
        
        XCTAssertEqual(sections.fastOperationSections.count, 1)
    }
    
    // MARK: - Helpers
    
    private func makeMainViewModelSections(
        _ sut: SUT? = nil,
        c2gFlag: C2GFlag,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .inactive,
        savingsAccountFlag: SavingsAccountFlag = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [MainSectionViewModel] {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
        return sut.makeMainViewModelSections(
            bannersBinder: .immediate,
            c2gFlag: c2gFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag,
            savingsAccountFlag: savingsAccountFlag
        )
    }
}

private extension Array where Element == MainSectionViewModel {
    
    var fastOperationSection: MainSectionFastOperationView.ViewModel? {
        
        fastOperationSections.first
    }
    
    var fastOperationSections: [MainSectionFastOperationView.ViewModel] {
        
        compactMap { $0 as? MainSectionFastOperationView.ViewModel }
    }
}
