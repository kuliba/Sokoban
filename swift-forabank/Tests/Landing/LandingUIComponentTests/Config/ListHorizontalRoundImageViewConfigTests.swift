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
    
    typealias Config = Landing.ListHorizontalRoundImage.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            backgroundColor: .black,
            title: .init(color: .textSecondary, font: .title),
            subtitle: .init(
                color: .textSecondary,
                background: .white,
                font: .title,
                cornerRadius: 12,
                padding: .init(horizontal: 6, vertical: 4)),
            detail: .init(color: .blue, font: .body),
            item: .init(cornerRadius: 2, width: 3, spacing: 4),
            cornerRadius: 5,
            spacing: 6,
            height: 9)
        
        XCTAssertEqual(config.backgroundColor, .black)
        XCTAssertEqual(config.title.color, .textSecondary)
        XCTAssertEqual(config.title.font, .title)
        XCTAssertEqual(config.subtitle.color, .textSecondary)
        XCTAssertEqual(config.subtitle.font, .title)
        XCTAssertEqual(config.subtitle.background, .white)
        XCTAssertEqual(config.subtitle.cornerRadius, 12)
        XCTAssertEqual(config.subtitle.padding.horizontal, 6)
        XCTAssertEqual(config.detail.color, .blue)
        XCTAssertEqual(config.detail.font, .body)
        XCTAssertEqual(config.item.cornerRadius, 2)
        XCTAssertEqual(config.item.width, 3)
        XCTAssertEqual(config.cornerRadius, 5)
        XCTAssertEqual(config.spacing, 6)
        XCTAssertEqual(config.height, 9)
    }
}
