//
//  CollateralLoanLandingGetShowcaseThemeTests.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import XCTest
import CollateralLoanLandingGetShowcaseUI

final class CollateralLoanLandingGetShowcaseThemeTests: XCTestCase {
    
    func test_map_shouldDeliverWhiteOnWhiteTheme() {
        
        assert(ModelTheme.white.map(), .white)
    }
    
    func test_map_shouldDeliverGrayOnGrayTheme() {
        
        assert(ModelTheme.gray.map(), .gray)
    }
    
    func test_map_shouldDeliverWhiteOnUnknownTheme() {

        assert(ModelTheme.unknown.map(), .white)
    }
    
    private typealias Theme = CollateralLoanLandingGetShowcaseTheme
    private typealias ModelTheme = CollateralLoanLandingGetShowcaseData.Product.Theme
    
    private func assert(
        _ receivedTheme: Theme,
        _ modelTheme: ModelTheme,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let theme = modelTheme.map()
        XCTAssertNoDiff(receivedTheme, theme, file: file, line: line)
    }
}
