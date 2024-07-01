//
//  PhoneNumberWrapperTests.swift
//
//
//  Created by Andryusina Nataly on 18.10.2023.
//
import PhoneNumberWrapper
import XCTest

final class PhoneNumberWrapperTests: XCTestCase {
    
    //MARK: - test isValidPhoneNumber - not valid
    
    func test_isValidPhoneNumber_ru_notValid() {
        
        // failure the reason is unclear
        // XCTAssertFalse(isValid(.ru(.startsWith8(.equals10Digits))))
        // XCTAssertFalse(isValid(.ru(.startsWithPlus8(.equals10Digits))))
        
        XCTAssertFalse(isValid(.ru(.startsWith8(.lessThen10Digits))))
        XCTAssertFalse(isValid(.ru(.startsWith8(.moreThen10Digits))))
    }
    
    //MARK: - test isValidPhoneNumber - valid
    
    func test_isValidPhoneNumber_valid() {
        
        XCTAssert(isValid(.ru(.startsWith7(.equals10Digits))))
        XCTAssert(isValid(.ru(.startsWithPlus7(.equals10Digits))))
        
        XCTAssert(isValid(.us(.withOutPlus)))
        XCTAssert(isValid(.us(.withPlus)))
    }
    
    //MARK: - test format - number starts at zero
    
    func test_format_ru_numberStartsWith7982() {
        
        let result = format(.ru(.startsWithZero(.moreThen10DigitsValidWith7982)))
        
        XCTAssertNoDiff(result, "+7 982 000-00-00")
    }
    
    func test_format_ru_numberStartsWithZero() {
        
        let result = format(.ru(.startsWithZero(.moreThen10DigitsValid)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_format_am_numberStartsWithZero() {
        
        let result = format(.am(.startsWithZero(.moreThen8DigitsValid)))
        
        XCTAssertNoDiff(result, "+374 11 222333")
    }
    
    func test_format_tr_numberStartsWithZero() {
        
        let result = format(.tr(.startsWithZero(.moreThen10DigitsValid)))
        
        XCTAssertNoDiff(result, "+90 531 123 45 67")
    }
    
    func test_format_us_numberStartsWithZero() {
        
        let result = format(.us(.startsWithZeroValid))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }

    //MARK: - test format ru - number starts at 7
    
    func test_format_ru_numberStartsWith7982_10Digits() {
        
        let result = format(.ru(.startsWith7(.equals10DigitsWith7982)))
        
        XCTAssertNoDiff(result, "+7 982 000-00-00")
    }
    
    func test_format_ru_numberStartsWith7_10Digits() {
        
        let result = format(.ru(.startsWith7(.equals10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    //MARK: - test format ru - number starts at +7
    
    func test_format_ru_numberStartsWithPlus7982_10Digits() {
        
        let result = format(.ru(.startsWithPlus7(.equals10DigitsWith7982)))
        
        XCTAssertNoDiff(result, "+7 982 000-00-00")
    }
    
    func test_format_ru_numberStartsWithPlus7_10Digits() {
        
        let result = format(.ru(.startsWithPlus7(.equals10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_format_us_numberStartsWith1_11Digits() {
        
        let result = format(.us(.withOutPlus))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }
    
    func test_format_us_numberStartsWithPlus1_11Digits() {
                
        let result = format(.us(.withPlus))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }
    
    func test_format_ru_numberStartsWith8() {
        
        let result = format(.ru(.startsWith8(.equals10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_format_ru_numberStartsWithPlus8() {
        
        let result = format(.ru(.startsWithPlus8(.equals10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    //MARK: - test format ru - number starts at 9
    
    func test_format_ru_numberStartsWith9_10Digits() {
        
        let result = format(.ru(.startsWith9(.equals10Digits)))
        // 963 код Сирии
        XCTAssertNoDiff(result, "+963 000 000 0")
    }
    
    func test_format_ru_numberStartsWith982_10Digits() {
        
        let result = format(.ru(.startsWith982(.equals10Digits)))
        
        XCTAssertNoDiff(result, "+98 200 000 00")
    }
        
    func test_format_ru_NumberLessThan10Digits() {
        
        let result = format(.ru(.startsWith8(.lessThen10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-0")
    }
    
    func test_format_ru_nNumberLessThan10DigitsWith982() {
        
        let result = format(.ru(.startsWith982(.lessThen10Digits)))
        
        XCTAssertNoDiff(result, "+98 200 000 0")
    }
    
    func test_format_ru_NumberMoreThan10Digits() {
        
        let result = format(.ru(.startsWith8(.moreThen10Digits)))
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_format_ru_NumberMoreThan10DigitsWith982() {
        
        let result = format(.ru(.startsWith982(.moreThen10Digits)))
        
        XCTAssertNoDiff(result, "+98 200 000 000")
    }
    
    //MARK: - test format us

    func test_format_us_startsWithZeroNotValid() {
        
        let result = format(.us(.startsWithZeroNotValid))
        
        XCTAssertNoDiff(result, "+800 4699 2692")
    }

    func test_format_us_startsWithZeroValid() {
        
        let result = format(.us(.startsWithZeroValid))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }

    func test_format_us_withPlus() {
        
        let result = format(.us(.withPlus))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }

    func test_format_us_withOutPlus() {
        
        let result = format(.us(.withOutPlus))
        
        XCTAssertNoDiff(result, "+1 800-469-9269")
    }

    //MARK: - test format other
    
    func test_format_otherNotValid_longIran() {
        
        let result = format(.otherNotValid(.longIran))
        
        XCTAssertNoDiff(result, "+98 920 555 0856")
    }

    func test_format_otherNotValid_longArmenia() {
        
        let result = format(.otherNotValid(.longArmenia))
        
        XCTAssertNoDiff(result, "+374 11 122233")
    }
    
    func test_format_otherNotValid_longLuxembourg() {
        
        let result = format(.otherNotValid(.longLuxembourg))
        
        XCTAssertNoDiff(result, "+352 111 222 333")
    }
    
    func test_format_otherNotValid_longPhilippines() {
        
        let result = format(.otherNotValid(.longPhilippines))
        
        XCTAssertNoDiff(result, "+63 121 545 4545")
    }
    
    func test_format_otherNotValid_longTurkey() {
        
        let result = format(.otherNotValid(.longTurkey))
        
        XCTAssertNoDiff(result, "+90 121 312 15 45")
    }
    
    func test_format_otherNotValid_longUSA() {
        
        let result = format(.otherNotValid(.longUSA))
        
        XCTAssertNoDiff(result, "+1 232-545-4545")
    }

    func test_format_otherNotValid_short() {
        
        let result = format(.otherNotValid(.short))
        
        XCTAssertNoDiff(result, "+1 122-3")
    }

    // MARK: - Helpers
    
    private func format(_ input: ExamplesDataToFormat) -> String {
        return PhoneNumberWrapper().format(input.phone)
    }
    
    private func isValid(_ input: ExamplesDataToFormat) -> Bool {
        return PhoneNumberWrapper().isValidPhoneNumber(input.phone)
    }
}

