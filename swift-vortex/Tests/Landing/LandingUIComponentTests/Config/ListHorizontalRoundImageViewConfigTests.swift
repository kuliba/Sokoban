//
//  ListHorizontalRoundImageViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListHorizontalRoundImageViewConfigTests: XCTestCase {
    
    typealias Config = UILanding.List.HorizontalRoundImage.Config
    
    func test_init_shouldSetBackgroundColor() {
        
       let config = makeConfig()
       XCTAssertEqual(config.backgroundColor, .black)
    }

    func test_init_shouldSetTitle() {
        
      let title = makeConfig().title
        
      XCTAssertEqual(title.color, .textSecondary)
      XCTAssertEqual(title.font, .title)
    }

    func test_init_shouldSetSubtitle() {
        
      let subtitle = makeConfig().subtitle
        
      XCTAssertEqual(subtitle.color, .textSecondary)
      XCTAssertEqual(subtitle.font, .title)
      XCTAssertEqual(subtitle.background, .white)
      XCTAssertEqual(subtitle.cornerRadius, 12)
      XCTAssertEqual(subtitle.padding.horizontal, 6)
    }

    func test_init_shouldSetDetail() {
        
      let detail = makeConfig().detail
        
      XCTAssertEqual(detail.color, .blue)
      XCTAssertEqual(detail.font, .body)
    }

    func test_init_shouldSetItem() {
        
      let item = makeConfig().item
        
      XCTAssertEqual(item.cornerRadius, 2)
      XCTAssertEqual(item.width, 3)
      XCTAssertEqual(item.size.height, 10)
      XCTAssertEqual(item.size.width, 1)
    }

    func test_init_shouldSetOtherProperties() {
        
      let config = makeConfig()
        
      XCTAssertEqual(config.cornerRadius, 5)
      XCTAssertEqual(config.spacing, 6)
      XCTAssertEqual(config.height, 9)
      XCTAssertEqual(config.paddings.horizontal, 2)
      XCTAssertEqual(config.paddings.vertical, 3)
    }

    // MARK: - Helpers
    
    func makeConfig() -> Config {
        
        return .init(
        backgroundColor: .black,
        title: .init(color: .textSecondary, font: .title),
        subtitle: .init(
            color: .textSecondary,
            background: .white,
            font: .title,
            cornerRadius: 12,
            padding: .init(horizontal: 6, vertical: 4)),
        detail: .init(
            color: .blue,
            font: .body),
        item: .init(
            cornerRadius: 2,
            width: 3,
            spacing: 4,
            size: .init(width: 1, height: 10)),
        cornerRadius: 5,
        spacing: 6,
        height: 9,
        paddings: .init(
            horizontal: 2,
            vertical: 3,
            vStackContentHorizontal: 16))
    }
}
