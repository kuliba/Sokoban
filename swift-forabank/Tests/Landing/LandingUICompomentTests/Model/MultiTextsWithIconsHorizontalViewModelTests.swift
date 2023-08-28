//
//  MultiTextsWithIconsHorizontalViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUICompoment
import XCTest

final class MultiTextsWithIconsHorizontalViewModelTests: XCTestCase {

    //MARK: - test init item
    
    func test_init_item_shouldSetAllValue() {
        
        let sut: Item = .init(
            id: "1",
            image: .bolt,
            title: .init(
                title: "String",
                font: .body,
                textColor: .grayColor
            ))
        
        XCTAssertEqual(sut.id, "1")
        XCTAssertEqual(sut.image, .bolt)
        XCTAssertEqual(sut.title?.title, "String")
        XCTAssertEqual(sut.title?.font, .body)
        XCTAssertEqual(sut.title?.textColor, .grayColor)
    }

    //MARK: - test init
    
    func test_init_shouldSetList() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.lists.count, Array<Item>.defaultValue.count)
    }

    // MARK: - Helpers
    
    typealias Item = MultiTextsWithIconsHorizontalViewModel.Item

    private func makeSUT(
        lists: [Item] = .defaultValue
    ) -> MultiTextsWithIconsHorizontalViewModel {
        
        let sut: MultiTextsWithIconsHorizontalViewModel = .init(lists: lists)

        return sut
    }
}
