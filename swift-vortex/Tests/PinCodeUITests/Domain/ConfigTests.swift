//
//  ConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

@testable import PinCodeUI

import XCTest

final class ConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let config: PinCodeView.Config = .init(
            buttonConfig: .defaultConfig,
            pinCodeConfig: .defaultValue
        )
        
        XCTAssertEqual(config.buttonConfig.font, .title)
        XCTAssertEqual(config.buttonConfig.textColor, .black)
        XCTAssertEqual(config.buttonConfig.buttonColor, .gray)
        
        XCTAssertEqual(config.pinCodeConfig.font, .title)
        XCTAssertEqual(config.pinCodeConfig.foregroundColor, .blue)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.normal, .gray)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.incorrect, .red)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.correct, .green)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.printing, .blue)
    }
}
