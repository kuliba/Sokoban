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
}
