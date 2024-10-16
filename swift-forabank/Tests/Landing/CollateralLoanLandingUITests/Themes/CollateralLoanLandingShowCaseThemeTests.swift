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
        
        // Arrange
        let result = CollateralLoanLandingShowCaseTheme.map(.white)

        // Assert
        XCTAssertEqual(result, .white)
    }
    
    func test_mapGrayTheme() {
        
        // Arrange
        let result = CollateralLoanLandingShowCaseTheme.map(.gray)

        // Assert
        XCTAssertEqual(result, .gray)
    }
    
    func test_mapDefaultTheme() {

        // Arrange
        let result = CollateralLoanLandingShowCaseTheme.map(.unknown)

        // Assert
        XCTAssertEqual(result, .white)
    }
}
