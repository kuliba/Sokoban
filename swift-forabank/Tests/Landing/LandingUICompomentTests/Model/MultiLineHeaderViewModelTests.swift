//
//  MultiLineHeaderViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUICompoment
import XCTest
import SwiftUI

final class MultiLineHeaderViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.backgroundColor.value, .black)
        XCTAssertEqual(sut.regularTextItems, Array.regularTextItems)
        XCTAssertEqual(sut.boldTextItems, Array.boldTextItems)
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
    
    typealias Item = MultiLineHeaderViewModel.Item
    typealias BackgroundColor = MultiLineHeaderViewModel.BackgroundColor

    private func makeSUT(
        backgroundColor: BackgroundColor = .black,
        regularTextItems: [Item] = .regularTextItems,
        boldTextItems: [Item] = .boldTextItems
    ) -> MultiLineHeaderViewModel {
        
        let sut: MultiLineHeaderViewModel = .init(
            backgroundColor: backgroundColor,
            regularTextItems: regularTextItems,
            boldTextItems: boldTextItems
        )

        return sut
    }
}

