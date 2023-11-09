//
//  MultiTypesButtonConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class MultiTypesButtonConfigTests: XCTestCase {
    
    typealias Config = UILanding.Multi.TypeButtons.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config = makeSUT(
            fonts: .init(into: .body, button: .title),
            black: .black,
            gray: .gray,
            white: .white,
            horizontal: 1,
            vertical: 2,
            cornerRadius: 3,
            spacing: 4,
            size: .init(imageInfo: 5, heightButton: 6),
            buttonColor: .blue,
            buttonText: .blue,
            foregroundBlack: .black,
            foregroundWhite: .white,
            paddings: .init(horizontal: 7, top: 12, bottom: 8)
        )
        
        XCTAssertEqual(config.cornerRadius, 3)
        XCTAssertEqual(config.spacing, 4)

        XCTAssertEqual(config.fonts.into, .body)
        XCTAssertEqual(config.fonts.button, .title)

        XCTAssertEqual(config.colors.background.black, .black)
        XCTAssertEqual(config.colors.background.white, .white)
        XCTAssertEqual(config.colors.background.gray, .gray)
        XCTAssertEqual(config.colors.foreground.fgBlack, .black)
        XCTAssertEqual(config.colors.foreground.fgWhite, .white)
        XCTAssertEqual(config.colors.button, .blue)
        XCTAssertEqual(config.colors.buttonText, .blue)

        XCTAssertEqual(config.sizes.imageInfo, 5)
        XCTAssertEqual(config.sizes.heightButton, 6)
        
        XCTAssertEqual(config.paddings.horizontal, 7)
        XCTAssertEqual(config.paddings.bottom, 8)
    }
    
    //MARK: - test background
    
    func test_background_styleBlack_shouldSetToBlack() {
        
        let config = makeSUT(black: .black)
        
        let background = config.backgroundColor(BackgroundColorType.black.rawValue)
        
        XCTAssertEqual(background, .black)
    }
    
    func test_background_styleWhite_shouldSetToWhite() {
        
        let config = makeSUT(white: .white)
        
        let background = config.backgroundColor(BackgroundColorType.white.rawValue)
        
        XCTAssertEqual(background, .white)
    }
    
    func test_background_styleGray_shouldSetToGray() {
        
        let config = makeSUT(gray: .gray)
        
        let background = config.backgroundColor(BackgroundColorType.gray.rawValue)
        
        XCTAssertEqual(background, .gray)
    }
    
    func test_background_styleUnknow_shouldSetToWhite() {
        
        let config = makeSUT()
        
        let background = config.backgroundColor("test")
        
        XCTAssertEqual(background, .white)
    }
    
    //MARK: - test textColor
    
    func test_textColor_styleBlack_shouldSetToWhite() {
        
        let config = makeSUT(white: .white)
        
        let textColor = config.textColor(BackgroundColorType.black.rawValue)
        
        XCTAssertEqual(textColor, .white)
    }
    
    func test_textColor_styleWhite_shouldSetToBlack() {
        
        let config = makeSUT(black: .black)
        
        let textColor = config.textColor(BackgroundColorType.white.rawValue)
        
        XCTAssertEqual(textColor, .black)
    }
    
    func test_textColor_styleGray_shouldSetToBlack() {
        
        let config = makeSUT(black: .black)
        
        let textColor = config.textColor(BackgroundColorType.gray.rawValue)
        
        XCTAssertEqual(textColor, .black)
    }
    
    func test_textColor_styleUnknow_shouldSetToBlack() {
        
        let config = makeSUT()
        
        let textColor = config.textColor("test")
        
        XCTAssertEqual(textColor, .black)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        fonts: Config.Fonts = .init(into: .body, button: .title),
        black: Color = .black,
        gray: Color = .gray,
        white: Color = .white,
        horizontal: CGFloat = 1,
        vertical: CGFloat = 2,
        cornerRadius: CGFloat = 3,
        spacing: CGFloat = 4,
        size: Config.Sizes = .init(imageInfo: 5, heightButton: 6),
        buttonColor: Color = .blue,
        buttonText: Color = .blue,
        foregroundBlack: Color = .black,
        foregroundWhite: Color = .white,
        paddings: Config.Paddings = .init(horizontal: 7, top: 12, bottom: 8)
    ) -> Config {
        
        return .init(
            paddings: paddings, cornerRadius: cornerRadius,
            fonts: fonts,
            spacing: spacing,
            sizes: size,
            colors: .init(
                background: .init(
                    black: black,
                    gray: gray,
                    white: white),
                button: buttonColor,
                buttonText: buttonColor,
                foreground: .init(fgBlack: foregroundBlack, fgWhite: foregroundWhite)))
    }
}

