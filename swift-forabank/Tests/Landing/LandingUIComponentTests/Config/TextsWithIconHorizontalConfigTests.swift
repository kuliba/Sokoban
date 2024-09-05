//
//  TextsWithIconHorizontalConfigTests.swift
//
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class TextsWithIconHorizontalConfigTests: XCTestCase {
    
    typealias Config = UILanding.TextsWithIconHorizontal.Config
    
    func test_init_shouldSetPaddings() {
        
        let config = makeConfig()
        
        XCTAssertEqual(config.paddings.horizontal, 16)
        XCTAssertEqual(config.paddings.vertical, 12)
    }

    func test_init_shouldSetBackgroundColorAndCornerRadius() {
        
        let config = makeConfig()
        
        XCTAssertEqual(config.backgroundColor, .blue)
        XCTAssertEqual(config.cornerRadius, 1)
    }

    func test_init_shouldSetCircleSize() {
        
        let config = makeConfig()
        
        XCTAssertEqual(config.circleSize, 2)
    }

    func test_init_shouldSetIcon() {
        
        let icon = makeConfig().icon
        
        XCTAssertEqual(icon.width, 2)
        XCTAssertEqual(icon.height, 3)
        XCTAssertEqual(icon.placeholderColor, .white)
        XCTAssertEqual(icon.padding.vertical, 12)
        XCTAssertEqual(icon.padding.leading, 16)
    }

    func test_init_shouldSetHeightAndSpacing() {
        
        let config = makeConfig()
        
        XCTAssertEqual(config.height, 3)
        XCTAssertEqual(config.spacing, 4)
    }

    func test_init_shouldSetText() {
        
        let text = makeConfig().text
        
        XCTAssertEqual(text.color, .gray)
        XCTAssertEqual(text.font, .body)
    }

    // MARK: - Helpers
    
    func makeConfig() -> Config {
        
        return .init(
            paddings: .init(
                horizontal: 16,
                vertical: 12),
            backgroundColor: .blue,
            cornerRadius: 1,
            circleSize: 2,
            icon: .init(
                width: 2,
                height: 3,
                placeholderColor: .white,
                padding: .init(
                    vertical: 12,
                    leading: 16)),
            height: 3, spacing: 4,
            text: .init(
                color: .gray,
                font: .body), 
            images: [:])
    }
}
