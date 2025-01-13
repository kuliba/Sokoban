//
//  ButtonConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

@testable import PinCodeUI

import XCTest
import SwiftUI

final class ButtonConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let buttonConfig: ButtonConfig = .init(
            font: .body,
            textColor: .black,
            buttonColor: .white
        )
        
        XCTAssertEqual(buttonConfig.font, .body)
        XCTAssertEqual(buttonConfig.textColor, .black)
        XCTAssertEqual(buttonConfig.buttonColor, .white)
    }
}
