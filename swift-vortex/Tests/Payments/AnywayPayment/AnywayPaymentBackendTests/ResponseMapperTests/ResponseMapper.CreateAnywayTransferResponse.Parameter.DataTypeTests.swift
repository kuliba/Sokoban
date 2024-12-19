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
        
        XCTAssertNil(makeDataType(""))
    }
    
    func test_init_shouldDeliverNilOnInvalid() {
        
        XCTAssertNil(makeDataType("abc"))
    }
    
    func test_init_shouldDeliverStringOnString() throws {
        
        try XCTAssertNoDiff(XCTUnwrap(makeDataType("%String")), DataType.string)
    }
    
    func test_init_shouldDeliverNilOnOneCharacterString() throws {
        
        XCTAssertNil(makeDataType("a"))
    }
    
    func test_init_shouldThrowOnTwoCharactersString() throws {
        
        XCTAssertNil(makeDataType("ab"))
    }
    
    func test_init_shouldDeliverNilOnMissingSeparator() throws {
        
        XCTAssertNil(makeDataType("=:1"))
    }
    
    func test_init_shouldDeliverOnePair() throws {
        
        XCTAssertNoDiff(makeDataType("=:1=a"), .pairs(nil, [.init("1", "a")]))
    }
    
    func test_init_shouldDeliverOnePairWithSelectedOnSelected() throws {
        
        XCTAssertNoDiff(makeDataType("=:1=a", value: "1"), .pairs(.init("1", "a"), [.init("1", "a")]))
    }
    
    func test_init_shouldDeliverOnePairWithLongStrings() throws {
        
        XCTAssertNoDiff(makeDataType("=;123=abcd"), .pairs(nil, [.init("123", "abcd")]))
    }
    
    func test_init_shouldDeliverOnePairWithLongStringsWithSelectedOnSelected() throws {
        
        XCTAssertNoDiff(makeDataType("=;123=abcd", value: "123"), .pairs(.init("123", "abcd"), [.init("123", "abcd")]))
    }
    
    func test_init_shouldDeliverTwoPairs() throws {
        
        XCTAssertNoDiff(makeDataType("=;1=a;2=b"), .pairs(
            nil, [
                .init("1", "a"),
                .init("2", "b")
            ]))
    }
    
    func test_init_shouldDeliverTwoPairsWithSelectedOnSelected() throws {
        
        XCTAssertNoDiff(makeDataType("=;1=a;2=b", value: "1"), .pairs(
            .init("1", "a"), [
                .init("1", "a"),
                .init("2", "b")
            ]))
    }
    
    func test_init_shouldDeliverTwoPairsWithLongStrings() throws {
        
        XCTAssertNoDiff(makeDataType("=*123=abcd*22=bbbbb"), .pairs(
            nil, [
                .init("123", "abcd"),
                .init("22", "bbbbb")
            ]))
    }
    
    func test_init_shouldDeliverTwoPairsWithLongStringsWithSelectedOnSelected() throws {
        
        XCTAssertNoDiff(makeDataType("=*123=abcd*22=bbbbb", value: "123"), .pairs(
            .init("123", "abcd"), [
                .init("123", "abcd"),
                .init("22", "bbbbb")
            ]))
    }
    
    func test_init_shouldDeliverPairsOnSampleDataType() throws {
        
        let dataType = "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ"
        
        XCTAssertNoDiff(makeDataType(dataType), .pairs(
            nil, [
                .init("ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"),
                .init("БЕЗ СТРАХОВОГО ВЗНОСА", "БЕЗ СТРАХОВОГО ВЗНОСА"),
                .init("ПРОЧИЕ ПЛАТЕЖИ", "ПРОЧИЕ ПЛАТЕЖИ")
            ]))
    }
    
    func test_init_shouldDeliverPairsOnSampleDataTypeWithSelectedOnSelected() throws {
        
        let dataType = "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ"
        
        XCTAssertNoDiff(makeDataType(dataType, value: "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"), .pairs(
            .init("ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"), [
                .init("ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС", "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"),
                .init("БЕЗ СТРАХОВОГО ВЗНОСА", "БЕЗ СТРАХОВОГО ВЗНОСА"),
                .init("ПРОЧИЕ ПЛАТЕЖИ", "ПРОЧИЕ ПЛАТЕЖИ")
            ]))
    }
    
    // MARK:- Helpers
    
    private typealias DataType = ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType
    
    private func makeDataType(
        _ string: String, value: String? = nil
    ) -> DataType? {
        
        return .init(string, value: value)
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType.Pair {
    
    init(_ key: String, _ value: String) {
        
        self.init(key: key, value: value)
    }
}
