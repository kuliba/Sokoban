//
//  ListDropDownTextsConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListDropDownTextsConfigTests: XCTestCase {
    
    typealias Config = UILanding.List.DropDownTexts.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValue() {
        
        let config: Config = .init(
            fonts: .init(
                title: .title,
                itemTitle: .body,
                itemDescription: .caption),
            colors: .init(
                title: .blue,
                itemTitle: .gray,
                itemDescription: .black),
            paddings: .init(
                titleTop: 10,
                list: 12,
                itemVertical: 13,
                itemHorizontal: 14),
            heights: .init(title: 1, item: 2),
            backgroundColor: .blue,
            cornerRadius: 12)
        
        XCTAssertEqual(config.fonts.title, .title)
        XCTAssertEqual(config.fonts.itemTitle, .body)
        XCTAssertEqual(config.fonts.itemDescription, .caption)

        XCTAssertEqual(config.colors.title, .blue)
        XCTAssertEqual(config.colors.itemTitle, .gray)
        XCTAssertEqual(config.colors.itemDescription, .black)
        
        XCTAssertEqual(config.paddings.titleTop, 10)
        XCTAssertEqual(config.paddings.list, 12)
        XCTAssertEqual(config.paddings.itemVertical, 13)
        XCTAssertEqual(config.paddings.itemHorizontal, 14)
        
        XCTAssertEqual(config.heights.title, 1)
        XCTAssertEqual(config.heights.item, 2)
        
        XCTAssertEqual(config.backgroundColor, .blue)
        XCTAssertEqual(config.cornerRadius, 12)
    }
}
