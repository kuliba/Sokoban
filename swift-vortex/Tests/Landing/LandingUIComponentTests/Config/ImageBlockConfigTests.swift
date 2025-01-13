//
//  ImageBlockConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ImageBlockConfigTests: XCTestCase {
    
    typealias Config = UILanding.ImageBlock.Config
    
    //MARK: - test init config

    func test_init_config_shouldSetAllValue() {
        
        let config = makeSUT(
            black: .black,
            gray: .gray,
            white: .white,
            defaultColor: .black,
            horizontal: 1,
            vertical: 2,
            cornerRadius: 3
        )
        
        XCTAssertEqual(config.background.black, .black)
        XCTAssertEqual(config.background.white, .white)
        XCTAssertEqual(config.background.gray, .gray)
        XCTAssertEqual(config.background.defaultColor, .black)
        
        XCTAssertEqual(config.paddings.horizontal, 1)
        XCTAssertEqual(config.paddings.vertical, 2)
        
        XCTAssertEqual(config.cornerRadius, 3)
    }
    
    //MARK: - test background
    
    func test_background_styleBlack_shouldSetToBlack() {
        
        let config = makeSUT(black: .black)
        
        let background = config.backgroundColor(BackgroundColorType.black.rawValue, defaultColor: .clear)
        
        XCTAssertEqual(background, .black)
    }
    
    func test_background_styleWhite_shouldSetToWhite() {
        
        let config = makeSUT(white: .white)
        
        let background = config.backgroundColor(BackgroundColorType.white.rawValue, defaultColor: .clear)
        
        XCTAssertEqual(background, .white)
    }

    func test_background_styleGray_shouldSetToGray() {
        
        let config = makeSUT(gray: .gray)
        
        let background = config.backgroundColor(BackgroundColorType.gray.rawValue, defaultColor: .clear)
        
        XCTAssertEqual(background, .gray)
    }

    func test_background_styleUnknow_shouldSetToDefaultColor() {
        
        let config = makeSUT()
        
        let background = config.backgroundColor("test", defaultColor: .yellow)
        
        XCTAssertEqual(background, .yellow)
    }
        
    // MARK: - Helpers
    
    private func makeSUT(
        black: Color = .black,
        gray: Color = .gray,
        white: Color = .white,
        defaultColor: Color = .black,
        horizontal: CGFloat = 1,
        vertical: CGFloat = 2,
        cornerRadius: CGFloat = 3,
        negativeBottomPadding: CGFloat = 0
    ) -> Config {
        
        return .init(
            background: .init(
                black: black,
                gray: gray,
                white: white,
                defaultColor: defaultColor),
            paddings: .init(horizontal: horizontal, vertical: vertical),
            cornerRadius: cornerRadius,
            negativeBottomPadding: negativeBottomPadding)
    }
}
