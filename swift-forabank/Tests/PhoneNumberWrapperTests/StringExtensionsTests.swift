//
//  StringExtensionsTests.swift
//
//
//  Created by Andryusina Nataly on 19.10.2023.
//
@testable import PhoneNumberWrapper
import XCTest

final class StringExtensionsTests: XCTestCase {

    // MARK: - test onlyDigits
    
    func test_onlyDigits_countLess10() {
        
        XCTAssertNoDiff("012340".onlyDigits(), "012340")
        XCTAssertNoDiff("00102340".onlyDigits(), "00102340")
        XCTAssertNoDiff("+1202340".onlyDigits(), "1202340")
    }

    func test_onlyDigits_count10() {
        
        XCTAssertNoDiff("0001202340".onlyDigits(), "0001202340")
        XCTAssertNoDiff("+0001202340".onlyDigits(), "0001202340")
        XCTAssertNoDiff("+0+00+1202340".onlyDigits(), "0001202340")
        XCTAssertNoDiff("+0-00-1202-340".onlyDigits(), "0001202340")
    }
    
    func test_onlyDigits_moreThan10() {
        
        XCTAssertNoDiff("+00012023401212".onlyDigits(), "12023401212")
        XCTAssertNoDiff("+0+00+12023404545".onlyDigits(), "12023404545")
        XCTAssertNoDiff("+0-00-1202-3404545".onlyDigits(), "12023404545")
        XCTAssertNoDiff("01234567891".onlyDigits(), "1234567891")
        XCTAssertNoDiff("001234567891".onlyDigits(), "1234567891")
        XCTAssertNoDiff("0001234567891".onlyDigits(), "1234567891")
    }
    
    // MARK: - test changeCodeIfNeeded
    
    func test_changeCodeIfNeeded_needChange() {
        
        XCTAssertNoDiff("89".changeCodeIfNeeded(), "79")
    }
    
    func test_changeCodeIfNeeded_notChange() {
        
        XCTAssertNoDiff("9".changeCodeIfNeeded(), "9")
        XCTAssertNoDiff("5".changeCodeIfNeeded(), "5")
        XCTAssertNoDiff("3".changeCodeIfNeeded(), "3")
        XCTAssertNoDiff("8".changeCodeIfNeeded(), "8")
        XCTAssertNoDiff("80".changeCodeIfNeeded(), "80")
    }

    // MARK: - test applyPatternOnPhoneNumber
    
    func test_applyPatternOnPhoneNumber_emptyPhone() {

        XCTAssertNoDiff(applyPatternOnPhoneNumber(.empty), "")
    }

    func test_applyPatternOnPhoneNumber_withOutDigits() {
        
        XCTAssertNoDiff("dgfdg".applyPatternOnPhoneNumber(mask: "X"), "")
    }
    
    func test_applyPatternOnPhoneNumber_1Digits() {
        
        XCTAssertNoDiff("7".applyPatternOnPhoneNumber(mask: .defaultMask), "+7")
        XCTAssertNoDiff("+7".applyPatternOnPhoneNumber(mask: .defaultMask), "+7")
        XCTAssertNoDiff("8".applyPatternOnPhoneNumber(mask: .defaultMask), "+8")
        XCTAssertNoDiff("5".applyPatternOnPhoneNumber(mask: .defaultMask), "+5")
    }

    func test_applyPatternOnPhoneNumber_moreThan1lessThan5Digits() {
       
        XCTAssertNoDiff("79".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 9")
        XCTAssertNoDiff("796".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 96")
        XCTAssertNoDiff("7963".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963")
        
        XCTAssertNoDiff("+79".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 9")
        XCTAssertNoDiff("+796".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 96")
        XCTAssertNoDiff("+7963".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963")
    
        XCTAssertNoDiff("89".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 9")
        XCTAssertNoDiff("896".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 96")
        XCTAssertNoDiff("8963".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963")
    }

    func test_applyPatternOnPhoneNumber_moreThan4lessThan8Digits() {
       
        XCTAssertNoDiff("79630".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 0")
        XCTAssertNoDiff("796300".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 00")
        XCTAssertNoDiff("7963000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000")
          
        XCTAssertNoDiff("+79630".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 0")
        XCTAssertNoDiff("+796300".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 00")
        XCTAssertNoDiff("+7963000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000")
        
        XCTAssertNoDiff("89630".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 0")
        XCTAssertNoDiff("896300".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 00")
        XCTAssertNoDiff("8963000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000")
    }

    func test_applyPatternOnPhoneNumber_moreThan8lessThan10Digits() {
       
        XCTAssertNoDiff("79630000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-0")
        XCTAssertNoDiff("796300000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00")
         
        XCTAssertNoDiff("+79630000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-0")
        XCTAssertNoDiff("+796300000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00")
         
        XCTAssertNoDiff("89630000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-0")
        XCTAssertNoDiff("896300000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00")
    }

    func test_applyPatternOnPhoneNumber_moreThan9Digits() {
        
        XCTAssertNoDiff("7963000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-0")
        XCTAssertNoDiff("79630000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-00")
        
        XCTAssertNoDiff("+7963000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-0")
        XCTAssertNoDiff("+79630000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-00")
        
        XCTAssertNoDiff("8963000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-0")
        XCTAssertNoDiff("89630000000".applyPatternOnPhoneNumber(mask: .defaultMask), "+7 963 000-00-00")
    }

    // MARK: - Helpers
    
    private func applyPatternOnPhoneNumber(
        _ input: ExamplesDataToFormat
    ) -> String {
        return input
            .phone
            .onlyDigits()
            .applyPatternOnPhoneNumber(mask: .defaultMask)
    }
    
    private func applyPatternOnPhoneNumber(
        _ input: String
    ) -> String {
        return input
            .onlyDigits()
            .applyPatternOnPhoneNumber(mask: .defaultMask)
    }
}

private extension String {
    static let defaultMask: Self = "+X XXX XXX-XX-XX"
}
