//
//  PageTitleConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

@testable import LandingUIComponent
import XCTest

final class PageTitleConfigTests: XCTestCase {
    
    typealias Config = UILanding.PageTitle.Config
    
    func test_init_config_shouldSetAllValue() {
        
        let config = makeSUT(
            title: .init(color: .black, font: .body),
            subtitle: .init(color: .blue, font: .caption))
        
        XCTAssertEqual(config.title.color, .black)
        XCTAssertEqual(config.title.font, .body)
        XCTAssertEqual(config.subtitle.color, .blue)
        XCTAssertEqual(config.subtitle.font, .caption)
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
        title: Config.Title = .init(color: .black, font: .body),
        subtitle: Config.Subtitle = .init(color: .blue, font: .caption)
    ) -> Config {
        
        return .init(
            title: title,
            subtitle: subtitle)
    }
}
