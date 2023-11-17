//
//  TimerViewConfigTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest

import SwiftUI

final class TimerViewConfigTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let timerViewConfig: TimerView.Config = .init(
            descFont: .body,
            descForegroundColor: .black,
            valueFont: .title,
            valueForegroundColor: .blue
        )
        
        XCTAssertEqual(timerViewConfig.descFont, .body)
        XCTAssertEqual(timerViewConfig.descForegroundColor, .black)
        XCTAssertEqual(timerViewConfig.valueFont, .title)
        XCTAssertEqual(timerViewConfig.valueForegroundColor, .blue)
    }
}
