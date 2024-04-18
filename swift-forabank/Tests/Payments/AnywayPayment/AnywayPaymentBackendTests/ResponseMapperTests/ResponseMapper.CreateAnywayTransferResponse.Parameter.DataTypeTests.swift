//
//  ResponseMapper.CreateAnywayTransferResponse.Parameter.DataTypeTests.swift
//
//
//  Created by Igor Malyarov on 03.04.2024.
//

@testable import AnywayPaymentBackend
import RemoteServices
import XCTest

final class ResponseMapper_CreateAnywayTransferResponse_Parameter_DataTypeTests: XCTestCase {
    
    func test_init_shouldDeliverNilOnEmpty() {
        
        XCTAssertNil(DataType(""))
    }
    
    func test_init_shouldDeliverNilOnInvalid() {
        
        XCTAssertNil(DataType("abc"))
    }
    
    func test_init_shouldDeliverStringOnString() throws {
        
        try XCTAssertNoDiff(XCTUnwrap(.init("%String")), DataType.string)
    }
    
    func test_init_shouldDeliverNilOnOneCharacterString() throws {
        
        XCTAssertNil(DataType("a"))
    }
    
    func test_init_shouldThrowOnTwoCharactersString() throws {
        
        XCTAssertNil(DataType("ab"))
    }
    
    func test_init_shouldDeliverNilOnMissingSeparator() throws {
        
        XCTAssertNil(DataType("=:1"))
    }
    
    func test_init_shouldDeliverOnePair() throws {
        
        XCTAssertNoDiff(DataType("=:1=a"), .pairs(.init("1", "a"), [.init("1", "a")]))
    }
    
    func test_init_shouldDeliverOnePairWithLongStrings() throws {
        
        XCTAssertNoDiff(DataType("=;123=abcd"), .pairs(.init("123", "abcd"), [.init("123", "abcd")]))
    }
    
    func test_init_shouldDeliverTwoPairs() throws {
        
        XCTAssertNoDiff(DataType("=;1=a;2=b"), .pairs(
            .init("1", "a"), [
            .init("1", "a"),
            .init("2", "b")
        ]))
    }
    
    func test_init_shouldDeliverTwoPairsWithLongStrings() throws {
        
        XCTAssertNoDiff(DataType("=*123=abcd*22=bbbbb"), .pairs(
            .init("123", "abcd"), [
            .init("123", "abcd"),
            .init("22", "bbbbb")
        ]))
    }
    
    func test_init_shouldDeliverPairsOnSampleDataType() throws {
        
        let dataType = "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ"
        
        XCTAssertNoDiff(DataType(dataType), .pairs(
            .init("ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"), [
            .init("ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"),
            .init("БЕЗ СТРАХОВОГО ВЗНОСА", "БЕЗ СТРАХОВОГО ВЗНОСА"),
            .init("ПРОЧИЕ ПЛАТЕЖИ", "ПРОЧИЕ ПЛАТЕЖИ")
        ]))
    }
    
    // MARK:- Helpers
    
    private typealias DataType = ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType.Pair {
    
    init(_ key: String, _ value: String) {
        
        self.init(key: key, value: value)
    }
}
