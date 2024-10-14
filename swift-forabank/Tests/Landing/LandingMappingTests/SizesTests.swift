//
//  SizesTests.swift
//
//
//  Created by Andryusina Nataly on 14.10.2024.
//

@testable import LandingMapping // for test internal init
import XCTest

final class SizesTests: XCTestCase {
    
    // MARK - test internal init(size: scale)
    
    func test_scaleMedium_shouldSetWidthHeightAsInSize() {
        
        assert("300x200", "medium", width: 300, height: 200)
    }
    
    func test_scaleSmall_shouldSetWidthHeight​​LessByQuarterOfSize() {
        
        assert("301x201", "small", width: 75, height: 50)
    }
    
    func test_scaleLarge_shouldSetWidthHeight​LargeThenQuarterOfSize() {
        
        assert("303x201", "large", width: 379, height: 251)
    }
    
    func test_sizeNotValid_shouldSetWidthHeight​ToZero() {
        
        assert("big small", "large", width: 0, height: 0)
    }
    
    func test_scaleNotValid_shouldSetWidthHeightAsInSize() {
        
        assert("303x201", "rtyrtyirtietyi", width: 303, height: 201)
    }
    
    func test_sizeNotValid_scaleNotValid_shouldSetWidthHeight​ToZero() {
        
        assert("dfdgdfgd", "rtyrtyirtietyi", width: 0, height: 0)
    }
        
    // MARK: helper
    
    private func assert(
        _ size: String,
        _ scale: String,
        width: Int,
        height: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let size = Sizes(size: size, scale: scale)
        
        XCTAssertNoDiff(size.width, width, "Expected width \"\(width)\" but got \"\(size.width)\" instead.", file: file, line: line)
        XCTAssertNoDiff(size.height, height, "Expected height \(height) but got \(size.height) instead.", file: file, line: line)
    }
}
