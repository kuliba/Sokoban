//
//  ListHorizontalRoundImageViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUICompoment
import XCTest
import SwiftUI

final class ListHorizontalRoundImageViewModelTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            title: "Title",
            items: [.init(
                id: "1",
                title: "2",
                image: .bolt,
                subInfo: .init(text: "3"),
                details: .init(
                    detailsGroupId: "4",
                    detailViewId: "5")
            )]
        )
        
        XCTAssertEqual(sut.title, "Title")
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.id, "1")
        XCTAssertEqual(sut.items.first?.title, "2")
        XCTAssertEqual(sut.items.first?.image, .bolt)
        XCTAssertEqual(sut.items.first?.subInfo?.text, "3")
        XCTAssertEqual(sut.items.first?.details?.detailsGroupId, "4")
        XCTAssertEqual(sut.items.first?.details?.detailViewId, "5")
    }
      
    // MARK: - Helpers
    
    typealias Item = ListHorizontalRoundImageViewModel.Item

    private func makeSUT(
        title: String?,
        items: [Item] = .defaultValue
    ) -> ListHorizontalRoundImageViewModel {
        
        let sut: ListHorizontalRoundImageViewModel = .init(
            title: title,
            items:items)

        return sut
    }
}
