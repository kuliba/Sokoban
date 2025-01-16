//
//  RootViewModelFactory+makeMainViewModelSectionsTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 20.12.2024.
//

@testable import Vortex
import XCTest
import RxViewModel
import Banners

final class RootViewModelFactory_makeMainViewModelSectionsTests: RootViewModelFactoryTests {
    
    func test_shouldMakeMainViewModelSections() {
        
        let sut = makeSUT().sut
        let bannersBinder = BannersBinder.immediate
        
        let sections = sut.makeMainViewModelSections(
            bannersBinder: bannersBinder,
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
    
    func test_makeOpenNewProductButtons() {
        
        let sut = makeSUT().sut
        let buttons = sut.makeOpenNewProductButtons(
            collateralLoanLandingFlag: .active, 
            savingsAccountFlag: .inactive,
            action: { _ in }
        )
        
        let ids = [
            "CARD",
            "DEPOSIT",
            "ACCOUNT",
            "STICKER",
            "LOAN",
            "INSURANCE",
            "MORTGAGE"
        ]
        
        XCTAssertTrue(buttons.count == 7)

        buttons.indices.forEach {
            XCTAssertTrue(buttons[$0].id == ids[$0])
        }
    }
}
