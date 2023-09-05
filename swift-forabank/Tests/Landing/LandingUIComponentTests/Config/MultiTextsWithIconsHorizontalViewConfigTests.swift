//
//  MultiTextsWithIconsHorizontalViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

@testable import LandingUIComponent
import XCTest

final class MultiTextsWithIconsHorizontalViewConfigTests: XCTestCase {

    typealias Config = Landing.MultiTextsWithIconsHorizontal.Config

    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let sut: Config = .init(
            color: .grayColor,
            font: .body)
        
        XCTAssertEqual(sut.color, .grayColor)
        XCTAssertEqual(sut.font, .body)
    }
}
