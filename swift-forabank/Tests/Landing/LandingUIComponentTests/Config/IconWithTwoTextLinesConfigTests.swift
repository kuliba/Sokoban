//
//  IconWithTwoTextLinesConfigTests.swift
//
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class IconWithTwoTextLinesConfigTests: XCTestCase {
    
    typealias Config = UILanding.IconWithTwoTextLines.Config
    
    func test_init_shouldSetPaddings() {
        
        let paddings = makeConfig().paddings
        
        XCTAssertEqual(paddings.horizontal, 16)
        XCTAssertEqual(paddings.vertical, 12)
    }
    
    func test_init_shouldSetIcon() {
        
        let icon = makeConfig().icon
        
        XCTAssertEqual(icon.size, 10)
        XCTAssertEqual(icon.paddingBottom, 11)
    }
    
    func test_init_shouldSetTitle() {
        
        let title = makeConfig().title
        
        XCTAssertEqual(title.font, .body)
        XCTAssertEqual(title.color, .black)
        XCTAssertEqual(title.paddingBottom, 1)
    }
    
    func test_init_shouldSetSubtitle() {
        
        let subtitle = makeConfig().subTitle
        
        XCTAssertEqual(subtitle.font, .title)
        XCTAssertEqual(subtitle.color, .blue)
        XCTAssertEqual(subtitle.paddingBottom, 2)
    }
    
    // MARK: - Helpers
    
    private func makeConfig() -> Config {
        
        return .init(
            paddings: .init(
                horizontal: 16,
                vertical: 12),
            icon: .init(
                size: 10,
                paddingBottom: 11),
            title: .init(
                font: .body,
                color: .black,
                paddingBottom: 1),
            subTitle: .init(
                font: .title,
                color: .blue,
                paddingBottom: 2))
    }
}
