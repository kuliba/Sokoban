//
//  MultiLineHeaderViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

@testable import LandingUICompoment
import XCTest
import SwiftUI

final class MultiLineHeaderViewConfigTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.backgroundColor.value, .black)
        XCTAssertEqual(sut.item.color, .black)
        XCTAssertEqual(sut.item.fontRegular, .title)
        XCTAssertEqual(sut.item.fontBold, .bold(.title)())
    }
    
    //MARK: - test textColor
    
    func test_init_backgroundColor_black_shouldSetTextColorToWhite() {
        
        let sut = makeSUT(
            backgroundColor: .black
        )
        
        XCTAssertEqual(sut.backgroundColor.value, .black)
        XCTAssertEqual(sut.textColor, .white)
    }
    
    func test_init_backgroundColor_gray_shouldSetTextColorToBlack() {
        
        let sut = makeSUT(
            backgroundColor: .gray
        )
        
        XCTAssertEqual(sut.backgroundColor.value, .gray)
        XCTAssertEqual(sut.textColor, .black)
    }
    
    func test_init_backgroundColor_white_shouldSetTextColorToBlack() {
        
        let sut = makeSUT(
            backgroundColor: .white
        )
        
        XCTAssertEqual(sut.backgroundColor.value, .white)
        XCTAssertEqual(sut.textColor, .black)
    }
    
    // MARK: - Helpers
    
    typealias BackgroundColor = MultiLineHeaderView.Config.BackgroundColor
    typealias Config = MultiLineHeaderView.Config
    typealias Item = MultiLineHeaderView.Config.Item
    
    private func makeSUT(
        backgroundColor: BackgroundColor = .black,
        item: Item = .defaultValueBlack
    ) -> Config {
        
        let sut: Config = .init(
            backgroundColor: backgroundColor,
            item: item
        )
        
        return sut
    }
}
