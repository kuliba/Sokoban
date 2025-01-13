//
//  VerticalSpacingConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class VerticalSpacingConfigTests: XCTestCase {

    typealias Config = UILanding.VerticalSpacing.Config

    func test_init_config_shouldSetAllValue() {
        
        let config: Config = makeSUT(big: 30, small: 20, negativeOffset: -10)
        
        XCTAssertEqual(config.spacing.big, 30)
        XCTAssertEqual(config.spacing.small, 20)
        XCTAssertEqual(config.spacing.negativeOffset, -10)
    }
    
    func test_setValue_typeBig_shouldSetValueBig() {
        
        let sut = makeSUT(big: 30)
        
        let value = sut.value(byType: .big)
        
        XCTAssertEqual(value, 30)
    }
    
    func test_setValue_typeSmall_shouldSetValueSmall() {
        
        let sut = makeSUT(small: 10)
        
        let value = sut.value(byType: .small)
        
        XCTAssertEqual(value, 10)
    }

    func test_setValue_typeNegative_shouldSetValueNegative() {
        
        let sut = makeSUT(negativeOffset: -4)
        
        let value = sut.value(byType: .negativeOffset)
        
        XCTAssertEqual(value, -4)
    }
    
    // MARK: - test background color
    
    func test_backgroundColor_StringIsWhite_shouldSetColorWhite() {
        
        let sut = makeSUT(white: .white)
        
        let value = sut.backgroundColor(BackgroundColorType.white)
        
        XCTAssertEqual(value, .white)
    }
    
    func test_backgroundColor_StringIsGray_shouldSetColorGray() {

        let sut = makeSUT(white: .white)
        
        let value = sut.backgroundColor(BackgroundColorType.gray)
        
        XCTAssertEqual(value, .gray)
    }

    func test_backgroundColor_StringIsBlack_shouldSetColorBlack() {

        let sut = makeSUT(white: .black)
        
        let value = sut.backgroundColor(BackgroundColorType.black)
        
        XCTAssertEqual(value, .black)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        big: CGFloat = 30,
        small: CGFloat = 20,
        negativeOffset: CGFloat = -10,
        black: Color = .black,
        gray: Color = .gray,
        white: Color = .white
    ) -> Config {
        
        return .init(
            spacing: .init(
                big: big,
                small: small,
                negativeOffset: negativeOffset),
            background: .init(black: black, gray: gray, white: white))
    }
}
