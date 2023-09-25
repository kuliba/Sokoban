//
//  MultiLineHeaderViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class MultiLineHeaderViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = UILanding.Multi.LineHeader(
            backgroundColor: "qqq",
            regularTextList: ["regularTextItem"],
            boldTextList: ["boldTextItem"]
        )
        
        XCTAssertEqual(sut.backgroundColor, "qqq")
        XCTAssertEqual(sut.regularTextList?.count, 1)
        XCTAssertEqual(sut.boldTextList?.count, 1)
        XCTAssertEqual(sut.regularTextList?.first, "regularTextItem")
        XCTAssertEqual(sut.boldTextList?.first, "boldTextItem")
    }
}

