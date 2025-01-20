//
//  SerialStampedCustomStringConvertibleTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.01.2025.
//

@testable import SerialComponents
@testable import RemoteServices
import XCTest

final class SerialStampedCustomStringConvertibleTests: XCTestCase {
    
    // MARK: - Tests for SerialStamped with Single Value
    
    func test_description_withSimpleValue_shouldReturnFormattedString() {
        
        let stamped = SerialComponents.SerialStamped(value: "test", serial: 1)
        
        XCTAssertNoDiff(stamped.description, "SerialStamped(serial: 1, value: test)")
    }
    
    func test_description_withCustomType_shouldReflectProperties() {
        
        let customValue = CustomType(id: 42, name: "Sample")
        let stamped = SerialComponents.SerialStamped(value: customValue, serial: 2)
        
        XCTAssertNoDiff(stamped.description, "SerialStamped(serial: 2, value: CustomType(id: 42, name: Sample))")
    }
    
    // MARK: - Tests for SerialStamped with Array
    
    func test_description_withSimpleArray_shouldReturnFormattedString() {
        
        let stamped = RemoteServices.SerialStamped(list: ["One", "Two"], serial: 3)
        
        XCTAssertNoDiff(stamped.description, "SerialStamped(serial: 3, list: [One, Two])")
    }
    
    func test_description_withComplexArray_shouldReflectProperties() {
        
        let items = [CustomType(id: 1, name: "A"), CustomType(id: 2, name: "B")]
        let stamped = RemoteServices.SerialStamped(list: items, serial: 4)
        
        XCTAssertNoDiff(stamped.description, "SerialStamped(serial: 4, list: [CustomType(id: 1, name: A), CustomType(id: 2, name: B)])")
    }
    
    // MARK: - Helpers
    
    private struct CustomType {
        
        let id: Int
        let name: String
    }
}
