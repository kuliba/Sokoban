//
//  MultiLineHeaderViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class MultiLineHeaderViewConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            item: .init(
                fontRegular: .title,
                fontBold: .bold(.title)()
            ))
        
        XCTAssertEqual(sut.item.fontRegular, .title)
        XCTAssertEqual(sut.item.fontBold, .bold(.title)())
    }
    
    //MARK: - test textColor
    
    func test_init_backgroundColor_black_shouldSetTextColorToWhite() {
        
        let sut = makeSUT()
        let textColor = sut.textColor("BLACK")
        
        XCTAssertEqual(textColor, .white)
    }
    
    func test_init_backgroundColor_gray_shouldSetTextColorToBlack() {
        
        let sut = makeSUT()
        let textColor = sut.textColor("GREY")

        XCTAssertEqual(textColor, .black)
    }
    
    func test_init_backgroundColor_white_shouldSetTextColorToBlack() {
        
        let sut = makeSUT()
        let textColor = sut.textColor("WHITE")

        XCTAssertEqual(textColor, .black)
    }
    
    //MARK: - test backgroundColor
    
    func test_init_backgroundColor_black_shouldSetBackgroundColorToBlack() {
        
        let sut = makeSUT()
        let backgroundColor = sut.backgroundColor("BLACK")
        
        XCTAssertEqual(backgroundColor, .black)
    }
    
    func test_init_backgroundColor_gray_shouldSetBackgroundColorToGray() {
        
        let sut = makeSUT()
        let backgroundColor = sut.backgroundColor("GREY")

        XCTAssertEqual(backgroundColor, .gray)
    }
    
    func test_init_backgroundColor_white_shouldSetBackgroundColorToWhite() {
        
        let sut = makeSUT()
        let backgroundColor = sut.backgroundColor("WHITE")

        XCTAssertEqual(backgroundColor, .white)
    }
    
    // MARK: - Helpers
    
    typealias Config = UILanding.Multi.LineHeader.Config
    typealias Item = UILanding.Multi.LineHeader.Config.Item
    
    private func makeSUT(
        item: Item = .defaultValueBlack
    ) -> Config {
        
        return .init(
            paddings: .init(horizontal: 16, vertical: 12), item: item,
            background: .init(black: .black, gray: .gray, white: .white),
            foreground: .init(fgBlack: .black, fgWhite: .white)
        )
    }
}
