//
//  MultiTextsWithIconsHorizontalViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

@testable import LandingUIComponent
import XCTest

final class MultiTextsWithIconsHorizontalViewConfigTests: XCTestCase {

    typealias Config = UILanding.Multi.TextsWithIconsHorizontal.Config
    
    func test_init_shouldSetColor() {
        
        let config = makeConfig()
        XCTAssertEqual(config.color, .grayColor)
    }

    func test_init_shouldSetFont() {
        
        let config = makeConfig()
        XCTAssertEqual(config.font, .body)
    }

    func test_init_shouldSetSize() {
        
        let config = makeConfig()
        XCTAssertEqual(config.size, 10)
    }

    func test_init_shouldSetPadding() {
        
        let config = makeConfig()
        
        XCTAssertEqual(config.padding.horizontal, 11)
        XCTAssertEqual(config.padding.vertical, 12)
        XCTAssertEqual(config.padding.itemVertical, 13)
    }

    // MARK: - Helpers
    
    func makeConfig() -> Config {
        
        return .init(
            color: .grayColor,
            font: .body,
            size: 10,
            padding: .init(
                horizontal: 11,
                vertical: 12,
                itemVertical: 13))
    }
}
