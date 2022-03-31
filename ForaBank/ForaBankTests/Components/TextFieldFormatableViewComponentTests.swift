//
//  TextFieldFormatableViewComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 17.03.2022.
//

import XCTest
@testable import ForaBank

class TextFieldFormatableViewComponentTests: XCTestCase {

    func testUpdateFormatted_Zero_Value_Add_Single_Update() throws {
        
        //given
        let formatter: NumberFormatter = .currency(with: "₽")
        let amount: Double = 0
        let value: String? = formatter.string(from: NSNumber(value: amount))
        let update = "6"
        let range = NSRange(location: 1, length: 0)
        
        // when
        let updatedString = TextFieldFormatableView.updateFormatted(value: value, inRange: range, update: update, formatter: formatter)
        
        // then
        XCTAssertEqual(updatedString, "6 ₽")
    }
    
    func testUpdateFormatted_Value_Add_Single_Update() throws {
        
        //given
        let formatter: NumberFormatter = .currency(with: "₽")
        let amount: Double = 123
        let value: String? = formatter.string(from: NSNumber(value: amount))
        let update = "6"
        let range = NSRange(location: 3, length: 0)
        
        // when
        let updatedString = TextFieldFormatableView.updateFormatted(value: value, inRange: range, update: update, formatter: formatter)
        
        // then
        XCTAssertEqual(updatedString, "1 236 ₽")
    }
    
    func testUpdateFormatted_Value_Remove_Single() throws {
        
        //given
        let formatter: NumberFormatter = .currency(with: "₽")
        let amount: Double = 6
        let value: String? = formatter.string(from: NSNumber(value: amount))
        let update = ""
        let range = NSRange(location: 0, length: 1)
        
        // when
        let updatedString = TextFieldFormatableView.updateFormatted(value: value, inRange: range, update: update, formatter: formatter)
        
        // then
        XCTAssertEqual(updatedString, "0 ₽")
    }
    
    func testUpdateFormatted_Zero_Value_Add_Comma_Update() throws {
        
        //given
        let formatter: NumberFormatter = .currency(with: "₽")
        let amount: Double = 0
        let value: String? = formatter.string(from: NSNumber(value: amount))
        let update = ","
        let range = NSRange(location: 1, length: 0)
        
        // when
        let updatedString = TextFieldFormatableView.updateFormatted(value: value, inRange: range, update: update, formatter: formatter)
        
        // then
        XCTAssertEqual(updatedString, "0, ₽")
    }
}
