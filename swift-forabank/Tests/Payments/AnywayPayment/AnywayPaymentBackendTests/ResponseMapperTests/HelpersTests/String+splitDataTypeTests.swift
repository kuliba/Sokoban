//
//  String+splitDataTypeTests.swift
//  
//
//  Created by Igor Malyarov on 03.04.2024.
//

@testable import AnywayPaymentBackend
import XCTest

final class String_splitDataTypeTests: XCTestCase {
    
    func test_dataType_shouldThrowOnEmpty() throws {
        
        try XCTAssertThrowsError("".splitDataType())
    }
    
    func test_dataType_shouldThrowOnOneCharacterString() throws {
        
        try XCTAssertThrowsError("a".splitDataType())
    }
    
    func test_dataType_shouldThrowOnTwoCharactersString() throws {
        
        try XCTAssertThrowsError("ab".splitDataType())
    }
    
    func test_dataType_shouldDeliverEmptyOnMissingSeparator() throws {
        
        let pairs = try "=:1".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), [])
        XCTAssertNoDiff(pairs.map(\.value), [])
    }
    
    func test_dataType_shouldDeliverEmptyOnNonMatchingSeparator() throws {
        
        let pairs = try ":=1-a".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), [])
        XCTAssertNoDiff(pairs.map(\.value), [])
    }
    
    func test_dataType_shouldDeliverOnePair() throws {
        
        let pairs = try "-:1-a".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), ["1"])
        XCTAssertNoDiff(pairs.map(\.value), ["a"])
    }
    
    func test_dataType_shouldDeliverOnePairWithLongStrings() throws {
        
        let pairs = try "-;123-abcd".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), ["123"])
        XCTAssertNoDiff(pairs.map(\.value), ["abcd"])
    }
    
    func test_dataType_shouldDeliverTwoPairs() throws {
        
        let pairs = try "=;1=a;2=b".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), ["1", "2"])
        XCTAssertNoDiff(pairs.map(\.value), ["a", "b"])
    }
    
    func test_dataType_shouldDeliverTwoPairsWithLongStrings() throws {
        
        let pairs = try "=*123=abcd*22=bbbbb".splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), ["123", "22"])
        XCTAssertNoDiff(pairs.map(\.value), ["abcd", "bbbbb"])
    }
    
    func test_dataType_shouldDeliverPairsOnSampleDataType() throws {
        
        let dataType = "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ"
        let pairs = try dataType.splitDataType()
        
        XCTAssertNoDiff(pairs.map(\.key), ["ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "БЕЗ СТРАХОВОГО ВЗНОСА", "ПРОЧИЕ ПЛАТЕЖИ"])
        XCTAssertNoDiff(pairs.map(\.value), ["ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "БЕЗ СТРАХОВОГО ВЗНОСА", "ПРОЧИЕ ПЛАТЕЖИ"])
    }
}
