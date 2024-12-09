//
//  RepeatButtonViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest

import SwiftUI

final class RepeatButtonViewConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValueWithDefaultTitle() {
        
        let config: RepeatButtonView.Config = .init(
            font: .body,
            foregroundColor: .black,
            backgroundColor: .blue) {}
        
        XCTAssertEqual(config.title, "Отправить повторно")
        XCTAssertEqual(config.font, .body)
        XCTAssertEqual(config.foregroundColor, .black)
        XCTAssertEqual(config.backgroundColor, .blue)
        XCTAssertNotNil(config.action)
    }
    
    func test_init_shouldSetAllValueWithCustomTitle() {
        
        let config: RepeatButtonView.Config = .init(
            title: "title",
            font: .caption,
            foregroundColor: .green,
            backgroundColor: .yellow) {}
        
        XCTAssertEqual(config.title, "title")
        XCTAssertEqual(config.font, .caption)
        XCTAssertEqual(config.foregroundColor, .green)
        XCTAssertEqual(config.backgroundColor, .yellow)
        XCTAssertNotNil(config.action)
    }
}
