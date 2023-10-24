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
    
    func test_onlyDigits_oneZero() {
        
        XCTAssertNoDiff("012340".onlyDigits(), "12340")
    }
    
    func test_onlyDigits_twoZero() {
        
        XCTAssertNoDiff("00102340".onlyDigits(), "102340")
    }

    func test_onlyDigits_threeZero() {
        
        XCTAssertNoDiff("0001202340".onlyDigits(), "1202340")
    }
    
    func test_onlyDigits_plus() {
        
        XCTAssertNoDiff("+1202340".onlyDigits(), "1202340")
    }

    func test_onlyDigits_plusWithZero() {
        
        XCTAssertNoDiff("+0001202340".onlyDigits(), "1202340")
    }

    func test_onlyDigits() {
        
        XCTAssertNoDiff("+0+00+1202340".onlyDigits(), "1202340")
    }
    
    func test_onlyDigits_dash() {
        
        XCTAssertNoDiff("+0-00-1202-340".onlyDigits(), "1202340")
    }
    
    // MARK: - test changeCodeIfNeeded
    
    func test_changeCodeIfNeeded_8_notChange() {
        
        XCTAssertNoDiff("8".changeCodeIfNeeded(), "7")
    }

    func test_changeCodeIfNeeded_89_needChange() {
        
        XCTAssertNoDiff("89".changeCodeIfNeeded(), "79")
    }

    func test_changeCodeIfNeeded_80_notChange() {
        
        XCTAssertNoDiff("80".changeCodeIfNeeded(), "70")
    }

    func test_changeCodeIfNeeded_9_notChange() {
        
        XCTAssertNoDiff("9".changeCodeIfNeeded(), "9")
    }

    // MARK: - test applyPatternOnPhoneNumber
    
    func test_applyPatternOnPhoneNumber_emptyPhone() {

        XCTAssertNoDiff(applyPatternOnPhoneNumber(.empty), "")
    }

    func test_applyPatternOnPhoneNumber_withOutDigits() {
        
        XCTAssertNoDiff("dgfdg".applyPatternOnPhoneNumber(), "")
    }
    
    func test_applyPatternOnPhoneNumber_startWith7_1Digits() {
        
        XCTAssertNoDiff("7".applyPatternOnPhoneNumber(), "+7")
    }
    
    func test_applyPatternOnPhoneNumber_startWithPlus7_1Digits() {
        
        XCTAssertNoDiff("+7".applyPatternOnPhoneNumber(), "+7")
    }
    
    func test_applyPatternOnPhoneNumber_startWith8_1Digits() {
        
        XCTAssertNoDiff("8".applyPatternOnPhoneNumber(), "+7")
    }
    
    func test_applyPatternOnPhoneNumber_startWithOther_1Digits() {
        
        XCTAssertNoDiff("5".applyPatternOnPhoneNumber(), "+5")
    }

    func test_applyPatternOnPhoneNumber_startWith7_moreThen1lessThen5Digits() {
       
        XCTAssertNoDiff("79".applyPatternOnPhoneNumber(), "+7 9")
        XCTAssertNoDiff("796".applyPatternOnPhoneNumber(), "+7 96")
        XCTAssertNoDiff("7963".applyPatternOnPhoneNumber(), "+7 963")
    }
    
    func test_applyPatternOnPhoneNumber_startWithPlus7_moreThen1lessThen5Digits() {
       
        XCTAssertNoDiff("+79".applyPatternOnPhoneNumber(), "+7 9")
        XCTAssertNoDiff("+796".applyPatternOnPhoneNumber(), "+7 96")
        XCTAssertNoDiff("+7963".applyPatternOnPhoneNumber(), "+7 963")
    }

    func test_applyPatternOnPhoneNumber_startWith8_moreThen1lessThen5Digits() {
       
        XCTAssertNoDiff("89".applyPatternOnPhoneNumber(), "+7 9")
        XCTAssertNoDiff("896".applyPatternOnPhoneNumber(), "+7 96")
        XCTAssertNoDiff("8963".applyPatternOnPhoneNumber(), "+7 963")
    }

    func test_applyPatternOnPhoneNumber_startWith7_moreThen4lessThen8Digits() {
       
        XCTAssertNoDiff("79630".applyPatternOnPhoneNumber(), "+7 963 0")
        XCTAssertNoDiff("796300".applyPatternOnPhoneNumber(), "+7 963 00")
        XCTAssertNoDiff("7963000".applyPatternOnPhoneNumber(), "+7 963 000")
    }
    
    func test_applyPatternOnPhoneNumber_startWithPlus7_moreThen4lessThen8Digits() {
       
        XCTAssertNoDiff("+79630".applyPatternOnPhoneNumber(), "+7 963 0")
        XCTAssertNoDiff("+796300".applyPatternOnPhoneNumber(), "+7 963 00")
        XCTAssertNoDiff("+7963000".applyPatternOnPhoneNumber(), "+7 963 000")
    }
    
    func test_applyPatternOnPhoneNumber_startWith8_moreThen4lessThen8Digits() {
       
        XCTAssertNoDiff("89630".applyPatternOnPhoneNumber(), "+7 963 0")
        XCTAssertNoDiff("896300".applyPatternOnPhoneNumber(), "+7 963 00")
        XCTAssertNoDiff("8963000".applyPatternOnPhoneNumber(), "+7 963 000")
    }

    func test_applyPatternOnPhoneNumber_startWith7_moreThen8lessThen10Digits() {
       
        XCTAssertNoDiff("79630000".applyPatternOnPhoneNumber(), "+7 963 000-0")
        XCTAssertNoDiff("796300000".applyPatternOnPhoneNumber(), "+7 963 000-00")
    }
    
    func test_applyPatternOnPhoneNumber_startWithPlus7_moreThen8lessThen10Digits() {
       
        XCTAssertNoDiff("+79630000".applyPatternOnPhoneNumber(), "+7 963 000-0")
        XCTAssertNoDiff("+796300000".applyPatternOnPhoneNumber(), "+7 963 000-00")
    }

    func test_applyPatternOnPhoneNumber_startWith8_moreThen8lessThen10Digits() {
       
        XCTAssertNoDiff("89630000".applyPatternOnPhoneNumber(), "+7 963 000-0")
        XCTAssertNoDiff("896300000".applyPatternOnPhoneNumber(), "+7 963 000-00")
    }

    func test_applyPatternOnPhoneNumber_startWith7_moreThen9Digits() {
        
        XCTAssertNoDiff("7963000000".applyPatternOnPhoneNumber(), "+7 963 000-00-0")
        XCTAssertNoDiff("79630000000".applyPatternOnPhoneNumber(), "+7 963 000-00-00")
    }
    
    func test_applyPatternOnPhoneNumber_startWithPlus7_moreThen9Digits() {
        
        XCTAssertNoDiff("+7963000000".applyPatternOnPhoneNumber(), "+7 963 000-00-0")
        XCTAssertNoDiff("+79630000000".applyPatternOnPhoneNumber(), "+7 963 000-00-00")
    }

    func test_applyPatternOnPhoneNumber_startWith8_moreThen9Digits() {
        
        XCTAssertNoDiff("8963000000".applyPatternOnPhoneNumber(), "+7 963 000-00-0")
        XCTAssertNoDiff("89630000000".applyPatternOnPhoneNumber(), "+7 963 000-00-00")
    }

    // MARK: - Helpers
    
    private func applyPatternOnPhoneNumber(
        _ input: ExamplesDataToFormat
    ) -> String {
        return input
            .phone
            .onlyDigits()
            .applyPatternOnPhoneNumber()
    }
    
    private func applyPatternOnPhoneNumber(
        _ input: String
    ) -> String {
        return input
            .onlyDigits()
            .applyPatternOnPhoneNumber()
    }
}
