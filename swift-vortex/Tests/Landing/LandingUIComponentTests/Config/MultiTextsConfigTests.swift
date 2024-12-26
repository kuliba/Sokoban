//
//  MultiTextsConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import LandingUIComponent
import XCTest
import SwiftUI

final class MultiTextsConfigTests: XCTestCase {
    
    typealias Config = UILanding.Multi.Texts.Config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            font: .body,
            colors: .init(text: .black, background: .blue),
            paddings: .init(
                main: .init(horizontal: 16, vertical: 8),
                inside: .init(horizontal: 15, vertical: 20)),
            cornerRadius: 12,
            spacing: 16
        )
        
        XCTAssertEqual(config.font, .body)
        XCTAssertEqual(config.colors.text, .black)
        XCTAssertEqual(config.colors.background, .blue)
        XCTAssertEqual(config.paddings.main.horizontal, 16)
        XCTAssertEqual(config.paddings.main.vertical, 8)
        XCTAssertEqual(config.paddings.inside.horizontal, 15)
        XCTAssertEqual(config.paddings.inside.vertical, 20)
        XCTAssertEqual(config.cornerRadius, 12)
        XCTAssertEqual(config.spacing, 16)
    }
}
