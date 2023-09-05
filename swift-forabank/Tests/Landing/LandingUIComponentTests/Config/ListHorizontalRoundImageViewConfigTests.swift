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
        
        let sut: Config = makeSUT()
        
        XCTAssertEqual(sut.backgroundColor, .black)
        XCTAssertEqual(sut.title.color, .textSecondary)
        XCTAssertEqual(sut.title.font, .title)
        XCTAssertEqual(sut.subtitle.color, .textSecondary)
        XCTAssertEqual(sut.subtitle.font, .title)
        XCTAssertEqual(sut.subtitle.background, .white)
        XCTAssertEqual(sut.title.color, .textSecondary)
        XCTAssertEqual(sut.detail.font, .body)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        backgroundColor: Color = .black,
        title: Config.Title = .defaultValue,
        subtitle: Config.Subtitle = .defaultValue,
        detail: Config.Detail = .defaultValue
    ) -> Config {
        
        let sut: Config = .init(
            backgroundColor: backgroundColor,
            title: title,
            subtitle: subtitle,
            detail: detail
        )
        
        return sut
    }
}
