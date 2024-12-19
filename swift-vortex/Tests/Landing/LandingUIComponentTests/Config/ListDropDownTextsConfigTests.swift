//
//  ListDropDownTextsConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListDropDownTextsConfigTests: XCTestCase {
    
    typealias Config = UILanding.List.DropDownTexts.Config
    
    func test_init_shouldSetFonts() {
        
        let fonts = makeConfig(
            fonts: .init(
                title: .title2,
                itemTitle: .title3,
                itemDescription: .largeTitle
            )
        ).fonts
        
        XCTAssertEqual(fonts.title, .title2)
        XCTAssertEqual(fonts.itemTitle, .title3)
        XCTAssertEqual(fonts.itemDescription, .largeTitle)
    }
    
    func test_init_shouldSetColors() {
        
        let colors = makeConfig(
            colors: .init(
                title: .red,
                itemTitle: .orange,
                itemDescription: .pink
            )
        ).colors
        
        XCTAssertEqual(colors.title, .red)
        XCTAssertEqual(colors.itemTitle, .orange)
        XCTAssertEqual(colors.itemDescription, .pink)
    }
    
    func test_init_shouldSetPaddings() {
        
        let paddings = makeConfig(
            paddings: .init(
                horizontal: 88,
                vertical: 87,
                titleTop: 86,
                titleHorizontal: 85,
                itemVertical: 84,
                itemHorizontal: 83
            )
        ).paddings
        
        XCTAssertEqual(paddings.horizontal, 88)
        XCTAssertEqual(paddings.vertical, 87)
        XCTAssertEqual(paddings.titleTop, 86)
        XCTAssertEqual(paddings.titleHorizontal, 85)
        XCTAssertEqual(paddings.itemVertical, 84)
        XCTAssertEqual(paddings.itemHorizontal, 83)
    }
    
    func test_init_shouldSetHeights() {
        
        let heights = makeConfig(
            heights: .init(
                title: 99,
                item: 98
            )
        ).heights
        
        XCTAssertEqual(heights.title, 99)
        XCTAssertEqual(heights.item, 98)
    }
    
    func test_init_shouldSetOtherProperties() {
        
        let config = makeConfig(
            backgroundColor: .pink,
            cornerRadius: 99,
            divider: .orange
        )
        
        XCTAssertEqual(config.backgroundColor, .pink)
        XCTAssertEqual(config.cornerRadius, 99)
        XCTAssertEqual(config.divider, .orange)
    }
    
    // MARK: - Helpers
    
    private func makeConfig(
        fonts: Config.Fonts = .init(
            title: .subheadline,
            itemTitle: .footnote,
            itemDescription: .callout
        ),
        colors: Config.Colors = .init(
            title: .orange,
            itemTitle: .pink,
            itemDescription: .red
        ),
        paddings: Config.Paddings = .init(
            horizontal: 91,
            vertical: 92,
            titleTop: 93,
            titleHorizontal: 94,
            itemVertical: 95,
            itemHorizontal: 96
        ),
        heights: Config.Heights = .init(
            title: 99,
            item: 111
        ),
        backgroundColor: Color = .green,
        cornerRadius: CGFloat = 48,
        divider: Color = .blue,
        chevronDownImage: Image = .init("some image")
    ) -> Config {
        
        .init(
            fonts: fonts,
            colors: colors,
            paddings: paddings,
            heights: heights,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            divider: divider,
            chevronDownImage: chevronDownImage
        )
    }
}
