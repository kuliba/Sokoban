//
//  PickerWithPreviewContainerViewTests.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest
import SwiftUI

final class PickerWithPreviewContainerViewTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let container: PickerWithPreviewContainerView = .init(
            model: .init(
                state: .monthlyOne,
                options: .all
            ),
            viewConfig: .defaulf,
            checkUncheckImage: .default,
            paymentAction: { },
            continueAction: { })
        
        XCTAssertEqual(container.viewConfig, .defaulf)
        XCTAssertEqual(container.checkUncheckImage, .default)
        XCTAssertNotNil(container.paymentAction)
        XCTAssertNotNil(container.continueAction)
        XCTAssertNotNil(container.body)
    }
}
