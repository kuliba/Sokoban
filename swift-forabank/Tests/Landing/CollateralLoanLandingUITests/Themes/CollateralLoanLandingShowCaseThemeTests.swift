//
//  CollateralLoanLandingShowCaseThemeTests.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import XCTest
import CollateralLoanLandingUI

final class CollateralLoanLandingShowCaseThemeTests: XCTestCase {
    
    func test_mapWhiteTheme() {
        
        let result = Theme.map(.white)
        XCTAssertNoDiff(result, .white)
    }
    
    func test_mapGrayTheme() {
        
        let result = Theme.map(.gray)
        assert(result, .gray)
    }
    
    func test_mapDefaultTheme() {

        let result = Theme.map(.unknown)
        assert(result, .white)
    }
    
    private typealias Theme = CollateralLoanLandingShowCaseTheme
    private typealias ModelTheme = CollateralLoanLandingShowCaseUIModel.Product.Theme
    
    private func mapped(_ theme: ModelTheme) -> Theme {
        Theme.map(theme)
    }
    
    private func assert(
        _ receivedTheme: Theme,
        _ modelTheme: ModelTheme,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let theme = mapped(modelTheme)
        XCTAssertNoDiff(theme, receivedTheme, file: file, line: line)
    }
}
