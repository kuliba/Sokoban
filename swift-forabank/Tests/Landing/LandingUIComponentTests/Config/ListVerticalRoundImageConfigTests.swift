//
//  ListVerticalRoundImageConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListVerticalRoundImageConfigTests: XCTestCase {
    
    typealias Config = UILanding.List.VerticalRoundImage.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            title: .init(
                font: .body,
                color: .gray,
                paddingHorizontal: 1,
                paddingTop: 2),
            spacings: .init(
                lazyVstack: 3,
                itemHstack: 4,
                buttonHStack: 5,
                itemVStackBetweenTitleSubtitle: 6),
            item: .init(
                imageWidthHeight: 7,
                fonts: .init(title: .title2, subtitle: .title3),
                colors: .init(title: .blue, subtitle: .clear),
                paddings: .init(horizontal: 8, vertical: 9)),
            listVerticalPadding: 10,
            componentSettings: .init(
                background: .black,
                cornerRadius: 11,
                horizontalPad: 12,
                verticalPad: 13),
            buttonSettings: .init(
                circleFill: .yellow,
                circleWidthHeight: 14,
                ellipsisForegroundColor: .black,
                text: .init(font: .body, color: .green),
                padding: .init(horizontal: 15, vertical: 16)))
        
        XCTAssertEqual(config.title.color, .gray)
        XCTAssertEqual(config.title.font, .body)
        XCTAssertEqual(config.title.paddingTop, 2)
        XCTAssertEqual(config.title.paddingHorizontal, 1)

        XCTAssertEqual(config.spacings.lazyVstack, 3)
        XCTAssertEqual(config.spacings.itemHstack, 4)
        XCTAssertEqual(config.spacings.buttonHStack, 5)
        XCTAssertEqual(config.spacings.itemVStackBetweenTitleSubtitle, 6)

        XCTAssertEqual(config.item.imageWidthHeight, 7)
        XCTAssertEqual(config.item.font.title, .title2)
        XCTAssertEqual(config.item.font.subtitle, .title3)
        XCTAssertEqual(config.item.color.title, .blue)
        XCTAssertEqual(config.item.color.subtitle, .clear)
        XCTAssertEqual(config.item.padding.horizontal, 8)
        XCTAssertEqual(config.item.padding.vertical, 9)
        
        XCTAssertEqual(config.listVerticalPadding, 10)

        XCTAssertEqual(config.componentSettings.background, .black)
        XCTAssertEqual(config.componentSettings.cornerRadius, 11)
        XCTAssertEqual(config.componentSettings.horizontalPad, 12)
        XCTAssertEqual(config.componentSettings.verticalPad, 13)

        XCTAssertEqual(config.buttonSettings.circleFill, .yellow)
        XCTAssertEqual(config.buttonSettings.circleWidthHeight, 14)
        XCTAssertEqual(config.buttonSettings.ellipsisForegroundColor, .black)
        XCTAssertEqual(config.buttonSettings.text.color, .green)
        XCTAssertEqual(config.buttonSettings.text.font, .body)
        XCTAssertEqual(config.buttonSettings.padding.horizontal, 15)
        XCTAssertEqual(config.buttonSettings.padding.vertical, 16)
    }
}
