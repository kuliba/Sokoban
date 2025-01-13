//
//  ColorsForPinTests.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

@testable import PinCodeUI

import XCTest
import SwiftUI

final class ColorsForPinTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let colors: PinCodeView.DotView.ColorsForPin = .init(
            normal: .black,
            incorrect: .red,
            correct: .green,
            printing: .blue)
        
        XCTAssertEqual(colors.normal, .black)
        XCTAssertEqual(colors.incorrect, .red)
        XCTAssertEqual(colors.correct, .green)
        XCTAssertEqual(colors.printing, .blue)
    }
    
    //MARK: - test colorByStyle
    
    func test_colorByStyle_isFilledTrue_shouldReturnCorrectValue_() {
        
        let colors: PinCodeView.DotView.ColorsForPin = .init(
            normal: .black,
            incorrect: .red,
            correct: .green,
            printing: .blue)
        
        XCTAssertEqual(colors.colorByStyle(.correct, isFilled: true), .green)
        XCTAssertEqual(colors.colorByStyle(.incorrect, isFilled: true), .red)
        XCTAssertEqual(colors.colorByStyle(.normal, isFilled: true), .black)
        XCTAssertEqual(colors.colorByStyle(.printing, isFilled: true), .blue)
    }
    
    func test_colorByStyle_isFilledFalse_shouldReturnColorForNormal() {
        
        let colors: PinCodeView.DotView.ColorsForPin = .init(
            normal: .black,
            incorrect: .red,
            correct: .green,
            printing: .blue)
        
        XCTAssertEqual(colors.colorByStyle(.correct, isFilled: false), .black)
        XCTAssertEqual(colors.colorByStyle(.incorrect, isFilled: false), .black)
        XCTAssertEqual(colors.colorByStyle(.normal, isFilled: false), .black)
        XCTAssertEqual(colors.colorByStyle(.printing, isFilled: false), .black)
    }
}
