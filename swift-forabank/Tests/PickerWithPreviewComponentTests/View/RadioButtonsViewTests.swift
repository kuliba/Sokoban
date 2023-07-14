//
//  RadioButtonsViewTests.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest
import SwiftUI

final class RadioButtonsViewTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let radioButtons: RadioButtonsView = .init(
            checkUncheckImage: .default,
            selection: .oneWithHtml,
            options: .allWithHtml,
            viewConfig: .defaulf,
            select: { _ in })
        
        XCTAssertEqual(radioButtons.checkUncheckImage, .default)
        XCTAssertEqual(radioButtons.selection, .oneWithHtml)
        XCTAssertEqual(radioButtons.options, .allWithHtml)
        XCTAssertEqual(radioButtons.viewConfig, .defaulf)
        XCTAssertNotNil(radioButtons.select)
        XCTAssertNotNil(radioButtons.body)
    }
}
