//
//  PinCodeConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest

final class PinCodeConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let config: PinCodeView.Config = .init(
            buttonConfig: .init(
                font: .title,
                textColor: .black,
                buttonColor: .gray
            ),
            pinCodeConfig: .init(
                font: .body,
                foregroundColor: .yellow,
                colorsForPin: .init(
                    normal: .gray,
                    incorrect: .red,
                    correct: .green,
                    printing: .white
                )
            )
        )
        
        XCTAssertEqual(config.buttonConfig.font, .title)
        XCTAssertEqual(config.buttonConfig.textColor, .black)
        XCTAssertEqual(config.buttonConfig.buttonColor, .gray)
        
        XCTAssertEqual(config.pinCodeConfig.font, .body)
        XCTAssertEqual(config.pinCodeConfig.foregroundColor, .yellow)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.normal, .gray)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.incorrect, .red)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.correct, .green)
        XCTAssertEqual(config.pinCodeConfig.colorsForPin.printing, .white)
    }
}
