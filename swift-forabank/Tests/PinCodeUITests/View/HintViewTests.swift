//
//  HintViewTests.swift
//  
//
//  Created by Andryusina Nataly on 27.07.2023.
//

@testable import PinCodeUI

import SwiftUI
import XCTest

final class HintViewTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let view = HintView()
                
        XCTAssertNotNil(view.body)
    }
}
