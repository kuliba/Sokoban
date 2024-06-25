//
//  String+compareVersionTests.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import ForaTools
import XCTest

final class String_compareVersionTests: XCTestCase {
    
    func test_compareVersion_shouldCompareMajorVersion() {
        
        XCTAssertEqual("1.0.0".compareVersion(to: "2.0.0"), .orderedAscending)
        XCTAssertEqual("2.0.0".compareVersion(to: "1.0.0"), .orderedDescending)
        XCTAssertEqual("1.0.0".compareVersion(to: "1.0.0"), .orderedSame)
    }
    
    func test_compareVersion_shouldCompareMinorVersion() {
        
        XCTAssertEqual("1.0.0".compareVersion(to: "1.1.0"), .orderedAscending)
        XCTAssertEqual("1.1.0".compareVersion(to: "1.0.0"), .orderedDescending)
        XCTAssertEqual("1.1.0".compareVersion(to: "1.1.0"), .orderedSame)
    }
    
    func test_compareVersion_shouldComparePatchVersion() {
        
        XCTAssertEqual("1.0.0".compareVersion(to: "1.0.1"), .orderedAscending)
        XCTAssertEqual("1.0.1".compareVersion(to: "1.0.0"), .orderedDescending)
        XCTAssertEqual("1.0.1".compareVersion(to: "1.0.1"), .orderedSame)
    }
    
    func test_compareVersion_shouldCompareMixedVersions() {
        
        XCTAssertEqual("1.2.3".compareVersion(to: "1.2.4"), .orderedAscending)
        XCTAssertEqual("1.2.4".compareVersion(to: "1.2.3"), .orderedDescending)
        XCTAssertEqual("1.2.3".compareVersion(to: "1.2.3"), .orderedSame)
    }
    
    func test_compareVersion_shouldCompareDifferentLengths() {
        
        XCTAssertEqual("1.0".compareVersion(to: "1.0.1"), .orderedAscending)
        XCTAssertEqual("1.0.1".compareVersion(to: "1.0"), .orderedDescending)
        XCTAssertEqual("1.2".compareVersion(to: "1.2.0"), .orderedSame)
        XCTAssertEqual("1.0".compareVersion(to: "1.0.0.0"), .orderedSame)
    }
}
