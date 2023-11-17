//
//  ButtonInfoTests.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

@testable import PinCodeUI

import XCTest
import SwiftUI

final class ButtonInfoTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let info: ButtonInfo = .init(
            value: "value",
            image: Image(systemName: "delete.backward"),
            type: .delete
        )
       
        XCTAssertNotNil(info.id)
        XCTAssertEqual(info.value, "value")
        XCTAssertEqual(info.image, Image(systemName: "delete.backward"))
        XCTAssertEqual(info.type, .delete)
    }
    
    func test_init_shouldSetImageNilIfImageNotSet() {
        
        let info: ButtonInfo = .init(
            value: "1",
            image: nil,
            type: .digit
        )
       
        XCTAssertNotNil(info.id)
        XCTAssertEqual(info.value, "1")
        XCTAssertNil(info.image)
        XCTAssertEqual(info.type, .digit)
    }
}
