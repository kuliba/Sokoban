//
//  ListHorizontalRoundImageViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListHorizontalRoundImageViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            title: "Title",
            items: [.init(
                imageMd5Hash: "1",
                title: "title",
                subInfo: "subtitle",
                detail: .init(groupId: "2", viewId: "3"))]
        )
        
        XCTAssertEqual(sut.title, "Title")
        XCTAssertEqual(sut.list.count, 1)
        XCTAssertEqual(sut.list.first?.title, "title")
        XCTAssertEqual(sut.list.first?.imageMd5Hash, "1")
        XCTAssertEqual(sut.list.first?.subInfo, "subtitle")
        XCTAssertEqual(sut.list.first?.detail?.groupId, "2")
        XCTAssertEqual(sut.list.first?.detail?.viewId, "3")
    }
    
    // MARK: - Helpers
    
    typealias Item = UILanding.List.HorizontalRoundImage.ListItem
    
    private func makeSUT(
        title: String?,
        items: [Item] = .defaultValue
    ) -> UILanding.List.HorizontalRoundImage {
        
        return .init(
            title: title,
            list: items
        )
    }
}
