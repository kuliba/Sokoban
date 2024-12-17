//
//  DoubleExtensionsTests.swift
//  ForaBankTests
//
//  Created by Dmitry Martynov on 20.12.2022.
//

import XCTest
@testable import ForaBank

class DoubleExtensionsTests: XCTestCase {

    func testRoundUp_Positive() throws {
     
        // given
        let inputArray: [Double] = [1, 1.01, 1.11, 1.19, 0.9, 0.1567999, 0.1501, 23.9800001, 23.99001, 23.00001, 23.90, 23.11, 0.1550, 0.16 / 0.1599]
        
        // when
        var resultArray = [Double]()
        inputArray.forEach { element in resultArray.append(element.roundUp(decimalPrecision: 2)) }
        
        // then
        let expectedArray: [Double] = [1.0, 1.01, 1.11, 1.19, 0.9, 0.16, 0.16, 23.99, 24.0, 23.01, 23.9, 23.11, 0.16, 1.01]
        for (index, result) in expectedArray.enumerated() {
            XCTAssertEqual(result, expectedArray[index])
        }
    }
    
    func testRoundDown_Positive() throws {
     
        // given
        let inputArray: [Double] = [1, 1.01, 1.11, 1.19, 0.9, 0.1567999, 0.1501, 23.9800001, 23.99001, 23.00001, 23.90, 23.11, 0.1550, 0.16 / 0.1599]
        
        // when
        var expectedArray = [Double]()
        inputArray.forEach { element in expectedArray.append(element.roundDown(decimalPrecision: 2)) }
        
        // then
        let rightArray: [Double] = [1.0, 1.01, 1.11, 1.19, 0.9, 0.15, 0.15, 23.98, 23.99, 23.0, 23.9, 23.11, 0.15, 1.0]
        for (index, result) in expectedArray.enumerated() {
            XCTAssertEqual(result, rightArray[index])
        }
    }
  
}
