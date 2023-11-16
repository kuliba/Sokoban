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
        
        XCTAssertEqual(sut.regularTextItems?.count, Array.regularTextItems.count)
        XCTAssertEqual(sut.boldTextItems?.count, Array.boldTextItems.count)
    }
    
    // MARK: - Helpers
    
    typealias Item = MultiLineHeaderViewModel.Item
    
    private func makeSUT(
        regularTextItems: [Item] = .regularTextItems,
        boldTextItems: [Item] = .boldTextItems
    ) -> MultiLineHeaderViewModel {
        
        let sut: MultiLineHeaderViewModel = .init(
            regularTextItems: regularTextItems,
            boldTextItems: boldTextItems)
        
        return sut
    }
}

