//
//  OptionWithMapImageTests.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest
import SwiftUI

final class OptionWithMapImageTests: XCTestCase {

    //MARK: - test init OptionWithMapImage

    func test_init_optionWithMapImage_shouldSetAllValue() {
        
        let option: OptionWithMapImage = .init(
            id: 1,
            value: "value",
            mapImage: .placeholder,
            title: "title"
        )
        
        XCTAssertEqual(option.id, 1)
        XCTAssertEqual(option.value, "value")
        XCTAssertEqual(option.mapImage, .placeholder)
        XCTAssertEqual(option.title, "title")
    }
}
