//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest

final class ViewConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let viewConfig: PickerWithPreviewContainerView.ViewConfig = .init(
            fontPickerSegmentTitle: .body,
            countinueButtonBackgroundColor: .blue,
            backgroundColor: .gray,
            leadingPadding: 25,
            trailingPadding: 15,
            navigationTitle: "title"
        )
        
        XCTAssertEqual(viewConfig.fontPickerSegmentTitle, .body)
        XCTAssertEqual(viewConfig.countinueButtonBackgroundColor, .blue)
        XCTAssertEqual(viewConfig.backgroundColor, .gray)
        XCTAssertEqual(viewConfig.leadingPadding, 25)
        XCTAssertEqual(viewConfig.trailingPadding, 15)
        XCTAssertEqual(viewConfig.navigationTitle, "title")
    }
}
