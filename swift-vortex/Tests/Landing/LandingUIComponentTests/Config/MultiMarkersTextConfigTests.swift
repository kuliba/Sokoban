//
//  MultiMarkersTextConfigTests.swift
//
//
//  Created by Andrew Kurdin on 22.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

typealias Config = UILanding.Multi.MarkersText.Config

final class MultiMarkersTextConfigTests: XCTestCase {
    
    func test_init_shouldSetAllProperties() {
        
        let config = UILanding.Multi.MarkersText.Config(
            colors: makeColors(),
            vstack: makeVStackSettings(),
            internalContent: makeInternalContent()
        )
        
        XCTAssertEqual(config.colors.foreground.black, .black)
        XCTAssertEqual(config.colors.foreground.white, .white)
        XCTAssertEqual(config.colors.foreground.defaultColor, .white)
        
        XCTAssertEqual(config.colors.backgroud.black, .black)
        XCTAssertEqual(config.colors.backgroud.white, .white)
        XCTAssertEqual(config.colors.backgroud.gray, .gray)
        XCTAssertEqual(config.colors.backgroud.defaultColor, .white)
        
        XCTAssertEqual(config.internalContent.cornerRadius, 12)
        XCTAssertEqual(config.internalContent.lineTextLeadingPadding, 6)
        XCTAssertEqual(config.internalContent.spacing, 4)
        XCTAssertEqual(config.internalContent.textFont, .body)
        
        XCTAssertEqual(config.vstack.padding.leading, 16)
        XCTAssertEqual(config.vstack.padding.trailing, 16)
        XCTAssertEqual(config.vstack.padding.vertical, 12)
    }
    
    func test_backgroundColor_validString_returnsCorrectColor() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.backgroundColor(.black), .black)
        XCTAssertEqual(config.backgroundColor(.gray), .gray)
        XCTAssertEqual(config.backgroundColor(.white), .white)
    }
    
    func test_backgroundColor_invalidString_returnsDefault() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.backgroundColor(.invalid), .white)
    }
    
    func test_foregroundColor_blackBG_returnsWhite() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.foregroundColor(.black), .white)
    }
    
    func test_foregroundColor_grayOrWhiteBG_returnsBlack() {
        
        XCTAssertEqual(defaultConfig().foregroundColor(.gray), .black)
        XCTAssertEqual(defaultConfig().foregroundColor(.white), .black)
    }
    
    func test_backgroundColorForPaddingWithCorners_padding_returnsBgColor() {
        
        XCTAssertEqual(defaultConfig().backgroundColor(.padding, .black), .black)
    }
    
    func test_getLeadingPadding_padding_returnsLeadingPadding() {
        
        let vstack = Config.VStackSettings(padding: .init(leading: 16, trailing: 0, vertical: 0))
        let config = defaultConfig(vstack: vstack)
        
        XCTAssertEqual(config.getLeadingPadding(.padding), 16)
    }
    
    func test_getTrailingPadding_padding_returnsTrailingPadding() {
        
        let vstack = Config.VStackSettings(padding: .init(leading: 0, trailing: 16, vertical: 0))
        let config = defaultConfig(vstack: vstack)
        
        XCTAssertEqual(config.getTrailingPadding(.padding), 16)
    }
    
    func test_getCornerRadius_cornersStyle_returnsCornerRadius() {
        
        let config = defaultConfig(
            internalContent: .init(spacing: 0, cornerRadius: 12, lineTextLeadingPadding: 10, textFont: .body)
        )
        
        XCTAssertEqual(config.getCornerRadius(.paddingWithCorners), 12)
    }
    
    func test_getVerticalPadding_paddingStyle_returnsVerticalPadding() {
        
        let vstack: Config.VStackSettings = .init(padding: .init(leading: 16, trailing: 15, vertical: 12))
        let config = defaultConfig(vstack: vstack)
        
        XCTAssertEqual(config.getVerticalPadding(.padding), 12)
    }
    
    func test_getVerticalPadding_fillStyle_returnsZero() {
        
        let config = defaultConfig()
        XCTAssertEqual(config.getVerticalPadding(.fill), 0)
    }
    
    func test_getDoubleHorizontalPadding_cornersStyle_returnsLeadingPadding() {
        
        let config = defaultConfig()
        XCTAssertEqual(config.getDoubleHorizontalPaddingForCornersView(.paddingWithCorners), 16)
    }
    
    func test_getDoubleHorizontalPadding_otherStyles_returnsZero() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.getDoubleHorizontalPaddingForCornersView(.padding), 0)
        XCTAssertEqual(config.getDoubleHorizontalPaddingForCornersView(.fill), 0)
    }
    
    // MARK: - Tests for 0/nil/clear
    
    func test_getLeadingPadding_fillStyle_returnsZero() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.getLeadingPadding(.fill), 0)
    }
    
    func test_getTrailingPadding_fillStyle_returnsZero() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.getTrailingPadding(.fill), 0)
    }
    
    func test_getCornerRadius_nonCornersStyle_returnsZero() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.getCornerRadius(.padding), 0)
    }
    
    func test_foregroundColor_invalidColor_returnsDefaultWhite() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.foregroundColor(.invalid), .white)
    }
    
    func test_backgroundColorForPaddingWithCorners_cornersStyle_returnsClear() {
        
        let config = defaultConfig()
        
        XCTAssertEqual(config.backgroundColor(.paddingWithCorners, .black), .clear)
    }
    
    func test_getCornerRadius_otherStyle_returnsZero() {
        
        XCTAssertEqual(defaultConfig().getCornerRadius(.padding), 0)
    }
    
    // MARK: Helpers
    func defaultConfig(
        colors: Config.Colors = .defaultValue,
        vstack: Config.VStackSettings = .defaultValue,
        internalContent: Config.InternalVStackWithContent = .defaultValue
    ) -> Config {
        
        return .init(
            colors: colors,
            vstack: vstack,
            internalContent: internalContent
        )
    }
    
    func makeColors(
        bgBlack: Color = .black,
        bgGray: Color = .gray,
        bgWhite: Color = .white
    ) -> Config.Colors {
        
        return .init(
            foreground: .init(
                black: .black,
                white: .white,
                defaultColor: .white
            ),
            backgroud: .init(
                gray: .gray,
                black: .black,
                white: .white,
                defaultColor: .white
            )
        )
    }
    
    func makeVStackSettings() -> UILanding.Multi.MarkersText.Config.VStackSettings {
        
        return .init(
            padding: .init(
                leading: 16,
                trailing: 16,
                vertical: 12
            )
        )
    }
    
    func makeInternalContent() -> UILanding.Multi.MarkersText.Config.InternalVStackWithContent {
        
        return .init(
            spacing: 4,
            cornerRadius: 12,
            lineTextLeadingPadding: 6,
            textFont: .body
        )
    }
}

extension Config.Colors {
    
    static let defaultValue: Self = .init(
        foreground: .init(
            black: .black,
            white: .white,
            defaultColor: .white
        ),
        backgroud: .init(
            gray: .gray,
            black: .black,
            white: .white,
            defaultColor: .white
        )
    )
}

extension Config.VStackSettings {
    
    static let defaultValue: Self = .init(
        padding: .init(
            leading: 16,
            trailing: 16,
            vertical: 12
        )
    )
}

extension Config.InternalVStackWithContent {
    
    static let defaultValue: Self = .init(
        spacing: 4,
        cornerRadius: 12,
        lineTextLeadingPadding: 6,
        textFont: .body
    )
}

extension String {
    
    static let black = "BLACK"
    static let gray = "GREY"
    static let white = "WHITE"
    
    static let fill = "FILL"
    static let padding = "PADDING"
    static let paddingWithCorners = "PADDINGWITHCORNERS"
    
    static let invalid = "INVALID135"
}
