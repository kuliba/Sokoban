//
//  CheckUncheckImagesTests.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest

final class CheckUncheckImagesTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let checkUncheckImage: CheckUncheckImages = .init(
            checkedImage: .checkImage,
            uncheckedImage: .unCheckImage
        )
        
        XCTAssertEqual(checkUncheckImage.checkedImage, .checkImage)
        XCTAssertEqual(checkUncheckImage.uncheckedImage, .unCheckImage)
    }
}
