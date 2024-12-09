//
//  ConfirmViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest

import SwiftUI

final class ConfirmViewConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValueWithDefaultTitle() {
        
        let config: ConfirmView.Config = .init(
            font: .body,
            foregroundColor: .black)
        
        XCTAssertEqual(config.font, .body)
        XCTAssertEqual(config.foregroundColor, .black)
    }
}
