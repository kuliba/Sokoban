//
//  ListHorizontalRectangleImageConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListHorizontalRectangleImageConfigTests: XCTestCase {
    
    typealias Config = UILanding.List.HorizontalRectangleImage.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            cornerRadius: 1,
            size: .init(height: 2, width: 3),
            paddings: .init(horizontal: 4, vertical: 5),
            spacing: 6)
        
        XCTAssertEqual(config.cornerRadius, 1)
        
        XCTAssertEqual(config.size.height, 2)
        XCTAssertEqual(config.size.width, 3)

        XCTAssertEqual(config.paddings.horizontal, 4)
        XCTAssertEqual(config.paddings.vertical, 5)

        XCTAssertEqual(config.spacing, 6)
    }
}
