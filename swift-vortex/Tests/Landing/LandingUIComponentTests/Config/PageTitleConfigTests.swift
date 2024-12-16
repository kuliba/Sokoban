//
//  PageTitleConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SharedConfigs

final class PageTitleConfigTests: XCTestCase {
    
    typealias Config = UILanding.PageTitle.Config
    
    func test_init_config_shouldSetAllValue() {
        
        let config = makeSUT(
            title: .init(textFont: .body, textColor: .black),
            subtitle: .init(textFont: .caption, textColor: .blue))
        
        XCTAssertEqual(config.title.textFont, .body)
        XCTAssertEqual(config.title.textColor, .black)
        XCTAssertEqual(config.subtitle.textFont, .caption)
        XCTAssertEqual(config.subtitle.textColor, .blue)
    }
    
    func test_background_transparencyTrue_shouldSetToClear() {
        
        let config = makeSUT()
        
        let background = config.background(true)
        
        XCTAssertEqual(background, .clear)
    }
    
    func test_background_transparencyFalse_shouldSetToWhite() {
        
        let config = makeSUT()
        
        let background = config.background(false)

        
        XCTAssertEqual(background, .white)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        title: TextConfig = .init(textFont: .title, textColor: .white),
        subtitle: TextConfig = .init(textFont: .body, textColor: .gray)
    ) -> Config {
        
        return .init(
            title: title,
            subtitle: subtitle)
    }
}
