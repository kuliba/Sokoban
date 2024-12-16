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
    
    func test_init_shouldSetPadding() {
        
      let config = makeConfig()
        
      XCTAssertEqual(config.padding.horizontal, 16)
      XCTAssertEqual(config.padding.vertical, 12)
    }

    func test_init_shouldSetTitle() {
        
      let title = makeConfig().title
        
      XCTAssertEqual(title.color, .gray)
      XCTAssertEqual(title.font, .body)
      XCTAssertEqual(title.paddingTop, 2)
      XCTAssertEqual(title.paddingHorizontal, 1)
    }

    func test_init_shouldSetSpacings() {
        
      let config = makeConfig()
        
      XCTAssertEqual(config.spacings.lazyVstack, 3)
      XCTAssertEqual(config.spacings.itemHstack, 4)
      XCTAssertEqual(config.spacings.buttonHStack, 5)
      XCTAssertEqual(config.spacings.itemVStackBetweenTitleSubtitle, 6)
    }
    
    func test_init_shouldSetDivider() {
        
      let config = makeConfig()
      XCTAssertEqual(config.divider, .grayLightest)
    }

    func test_init_shouldSetItem() {
        
      let item = makeConfig().item
        
      XCTAssertEqual(item.imageWidthHeight, 7)
      XCTAssertEqual(item.font.title, .title2)
      XCTAssertEqual(item.font.subtitle, .title3)
      XCTAssertEqual(item.color.title, .blue)
      XCTAssertEqual(item.color.subtitle, .clear)
      XCTAssertEqual(item.padding.horizontal, 8)
      XCTAssertEqual(item.padding.vertical, 9)
    }

    func test_init_shouldSetListVerticalPadding() {
        
      let config = makeConfig()
      XCTAssertEqual(config.listVerticalPadding, 10)
    }

    func test_init_shouldSetComponentSettings() {
        
      let settings = makeConfig().componentSettings
        
      XCTAssertEqual(settings.background, .grayColor)
      XCTAssertEqual(settings.cornerRadius, 12)
    }

    func test_init_shouldSetButtonSettings() {
        
      let settings = makeConfig().buttonSettings
        
      XCTAssertEqual(settings.circleFill, .yellow)
      XCTAssertEqual(settings.circleWidthHeight, 14)
      XCTAssertEqual(settings.ellipsisForegroundColor, .black)
      XCTAssertEqual(settings.text.color, .green)
      XCTAssertEqual(settings.text.font, .body)
      XCTAssertEqual(settings.padding.horizontal, 15)
      XCTAssertEqual(settings.padding.vertical, 16)
    }
    
    // MARK: - Helpers
    
    func makeConfig() -> Config {
        
        return .init(
            padding: .init(
                horizontal: 16,
                vertical: 12),
            title: .init(
                font: .body,
                color: .gray,
                paddingHorizontal: 1,
                paddingTop: 2),
            divider: .grayLightest, spacings: .init(
                lazyVstack: 3,
                itemHstack: 4,
                buttonHStack: 5,
                itemVStackBetweenTitleSubtitle: 6),
            item: .init(
                imageWidthHeight: 7, 
                hstackAlignment: .center,
                font: .init(title: .title2, titleWithOutSubtitle: .title2, subtitle: .title3),
                color: .init(title: .blue, subtitle: .clear),
                padding: .init(horizontal: 8, vertical: 9)),
            listVerticalPadding: 10,
            componentSettings: .init(background: .grayColor, cornerRadius: 12),
            buttonSettings: .init(
                circleFill: .yellow,
                circleWidthHeight: 14,
                ellipsisForegroundColor: .black,
                text: .init(font: .body, color: .green),
                padding: .init(horizontal: 15, vertical: 16)))
    }
}
