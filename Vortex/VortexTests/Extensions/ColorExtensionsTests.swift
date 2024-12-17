//
//  ColorExtensionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 03.06.2024.
//

@testable import ForaBank
import XCTest
import SwiftUI

final class ColorExtensionsTests: XCTestCase {

    // MARK: - test isDarkColor
    
    func test_white_shouldNotDark() {
        
        XCTAssertFalse(Color.white.isDarkColor())
    }
    
    func test_bgIconGrayLightest_shouldNotDark() {
        
        XCTAssertFalse(Color.bgIconGrayLightest.isDarkColor())
    }
    
    func test_gray_shouldIsDark() {
        
        XCTAssertTrue(Color.gray.isDarkColor())
    }

    func test_yellow_shouldIsDark() {
        
        XCTAssertTrue(Color.yellow.isDarkColor())
    }
}
