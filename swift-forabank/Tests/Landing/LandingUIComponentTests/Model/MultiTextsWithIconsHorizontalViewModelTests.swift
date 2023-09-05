//
//  MultiTextsWithIconsHorizontalViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUIComponent
import XCTest

final class MultiTextsWithIconsHorizontalViewModelTests: XCTestCase {
    
    //MARK: - test init item
    
    func test_init_item_shouldSetAllValue() {
        
        let sut: Item = .init(
            image: .bolt,
            title: "String"
        )
        
        XCTAssertEqual(sut.image, .bolt)
        XCTAssertEqual(sut.title, "String")
    }
        
    // MARK: - Helpers
    
    typealias Item = Landing.MultiTextsWithIconsHorizontal.Item
    
    private func makeSUT(
        lists: [Item]
    ) -> Landing.MultiTextsWithIconsHorizontal {
        
       return .init(
        lists: lists
       )
    }
}
