//
//  ConverterFormatterTests.swift
//
//
//  Created by Igor Malyarov on 05.07.2024.
//

import ForaTools
import XCTest

final class ConverterFormatterTests: XCTestCase {
    
    // MARK: - cleanup
    
    func test_cleanup_shouldRemoveWhiteSpaces() {
        
        XCTAssertNoDiff(cleanup(" 12"), "12")
        XCTAssertNoDiff(cleanup("12 "), "12")
        XCTAssertNoDiff(cleanup(" 12 "), "12")
        XCTAssertNoDiff(cleanup("  12  "), "12")
        
        XCTAssertNoDiff(cleanup(" 12,345"), "12,345")
        XCTAssertNoDiff(cleanup("12,345 "), "12,345")
        XCTAssertNoDiff(cleanup(" 12,345 "), "12,345")
        XCTAssertNoDiff(cleanup("  12,345  "), "12,345")
        
        XCTAssertNoDiff(cleanup(" 1 234,5"), "1234,5")
        XCTAssertNoDiff(cleanup("1 234,5 "), "1234,5")
        XCTAssertNoDiff(cleanup(" 1 234,5 "), "1234,5")
        XCTAssertNoDiff(cleanup("  1 234,5  "), "1234,5")
    }
    
    func test_cleanup_shouldRemoveWhiteSpaces_en_US() {
        
        XCTAssertNoDiff(cleanup(" 12", localeIdentifier: "en_US"), "12")
        XCTAssertNoDiff(cleanup("12 ", localeIdentifier: "en_US"), "12")
        XCTAssertNoDiff(cleanup(" 12 ", localeIdentifier: "en_US"), "12")
        XCTAssertNoDiff(cleanup("  12  ", localeIdentifier: "en_US"), "12")
        
        XCTAssertNoDiff(cleanup(" 12.345", localeIdentifier: "en_US"), "12.345")
        XCTAssertNoDiff(cleanup("12.345 ", localeIdentifier: "en_US"), "12.345")
        XCTAssertNoDiff(cleanup(" 12.345 ", localeIdentifier: "en_US"), "12.345")
        XCTAssertNoDiff(cleanup("  12.345  ", localeIdentifier: "en_US"), "12.345")
        
        XCTAssertNoDiff(cleanup(" 1 234.5", localeIdentifier: "en_US"), "1234.5")
        XCTAssertNoDiff(cleanup("1 234.5 ", localeIdentifier: "en_US"), "1234.5")
        XCTAssertNoDiff(cleanup(" 1 234.5 ", localeIdentifier: "en_US"), "1234.5")
        XCTAssertNoDiff(cleanup("  1 234.5  ", localeIdentifier: "en_US"), "1234.5")
    }
    
    func test_cleanup_shouldRemoveNonDigits() {
        
        XCTAssertNoDiff(cleanup(" a1b2cd "), "12")
        XCTAssertNoDiff(cleanup(" a12b,b345d "), "12,345")
        XCTAssertNoDiff(cleanup(" a 1b c23d4e,f5g e "), "1234,5")
    }
    
    // MARK: - convertAndFormat
    
    func test_convertAndFormat_shouldFormatWithDelimiter() {
        
        XCTAssertNoDiff(convertAndFormat("12,345", delimiter: "-"), "12-345")
        XCTAssertNoDiff(convertAndFormat("12.345", delimiter: ",", localeIdentifier: "en_US"), "12,345")
        
        XCTAssertNoDiff(convertAndFormat("1 234,56", delimiter: "-"), "1234-56")
        XCTAssertNoDiff(convertAndFormat("1,234.56", delimiter: "-", localeIdentifier: "en_US"), "1234-56")
        
        XCTAssertNil(convertAndFormat("", delimiter: "-"))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ConverterFormatter
    
    private func makeSUT(
        locale: Locale = .init(identifier: "ru_RU"),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(locale: locale)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func cleanup(
        sut: SUT? = nil,
        _ input: String,
        localeIdentifier identifier: String = "ru_RU"
    ) -> String {
        
        let locale = Locale(identifier: identifier)
        let sut = sut ?? makeSUT(locale: locale)
        return sut.cleanup(input)
    }
    
    private func convertAndFormat(
        sut: SUT? = nil,
        _ input: String,
        delimiter: Character,
        localeIdentifier identifier: String = "ru_RU"
    ) -> String? {
        
        let locale = Locale(identifier: identifier)
        let sut = sut ?? makeSUT(locale: locale)
        return sut.convertAndFormat(input, delimiter: delimiter)
    }
}
