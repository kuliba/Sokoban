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
        
        let sections = sut.makeMainViewModelSections(bannersBinder: bannersBinder)
        
        XCTAssertTrue(sections.count == 6)
        XCTAssertTrue(sections[0] is MainSectionProductsView.ViewModel)
        XCTAssertTrue(sections[1] is MainSectionFastOperationView.ViewModel)
        XCTAssertTrue(sections[2] is MainSectionPromoView.ViewModel)
        XCTAssertTrue(sections[3] is MainSectionCurrencyMetallView.ViewModel)
        XCTAssertTrue(sections[4] is MainSectionOpenProductView.ViewModel)
        XCTAssertTrue(sections[5] is MainSectionAtmView.ViewModel)
    }
}
