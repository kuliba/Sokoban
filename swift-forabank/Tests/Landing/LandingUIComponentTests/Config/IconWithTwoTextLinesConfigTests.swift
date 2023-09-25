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
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            icon: .init(
                size: 10,
                paddingBottom: 11),
            horizontalPadding: 12,
            title: .init(font: .body, color: .black, paddingBottom: 1),
            subTitle: .init(font: .title, color: .blue, paddingBottom: 2))
        
        XCTAssertEqual(config.icon.size, 10)
        XCTAssertEqual(config.icon.paddingBottom, 11)
        XCTAssertEqual(config.horizontalPadding, 12)
        
        XCTAssertEqual(config.title.font, .body)
        XCTAssertEqual(config.title.color, .black)
        XCTAssertEqual(config.title.paddingBottom, 1)
        
        XCTAssertEqual(config.subTitle.font, .title)
        XCTAssertEqual(config.subTitle.color, .blue)
        XCTAssertEqual(config.subTitle.paddingBottom, 2)
    }
}
