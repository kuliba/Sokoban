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
            md5hash: "1",
            title: "String"
        )
        
        XCTAssertEqual(sut.md5hash, "1")
        XCTAssertEqual(sut.title, "String")
    }
        
    // MARK: - Helpers
    
    typealias Item = UILanding.Multi.TextsWithIconsHorizontal.Item
    
    private func makeSUT(
        lists: [Item]
    ) -> UILanding.Multi.TextsWithIconsHorizontal {
        
       return .init(
        lists: lists
       )
    }
}
