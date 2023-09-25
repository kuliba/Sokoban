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
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            backgroundColor: .blue,
            cornerRadius: 1,
            icon: .init(iconSize: 2, placeholderColor: .white),
            height: 3,
            spacing: 4,
            text: .init(color: .gray, font: .body))
        
        XCTAssertEqual(config.backgroundColor, .blue)
        XCTAssertEqual(config.cornerRadius, 1)
        XCTAssertEqual(config.height, 3)
        XCTAssertEqual(config.spacing, 4)
        
        XCTAssertEqual(config.icon.size, 2)
        XCTAssertEqual(config.icon.placeholderColor, .white)
        
        XCTAssertEqual(config.text.color, .gray)
        XCTAssertEqual(config.text.font, .body)
    }
}
