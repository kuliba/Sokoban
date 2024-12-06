//
//  TextFieldPhoneNumberViewComponentsTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 26.10.2022.
//

import XCTest
@testable import ForaBank

final class TextFieldPhoneNumberViewComponentsTests: XCTestCase {
    
    func test_updateMasked_shouldEnterCountryCode() throws {
        
        //given
        let value = ""
        let update = "7"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+7")
    }
    
    func test_updateMasked_shouldNotSubstituteNonMatchingUpdateWithCountryCode_onNilValue() throws {
        
        //given
        let value: String? = nil
        let update = "7"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+7")
    }
    
    func test_updateMasked_shouldSubstituteMatchingUpdateWithCountryCode_onNilValue() throws {
        
        //given
        let value: String? = nil
        let update = "89"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+7 9")
    }
    
    func test_updateMasked_shouldSubstituteMatchingUpdateWithCountryCode_onNilValue2() throws {
        
        //given
        let value: String? = nil
        let update = "9"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+9")
    }
    
    func test_updateMasked_shouldRemoveFirstLetter() throws {
        
        //given
        let value = ""
        let update = "п"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "")
    }
    
    func test_updateMasked_shouldRemoveSymbol_onDelete() throws {
        
        //given
        let value = "+7"
        let update = ""
        let range = NSRange(location: 1, length: 1)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, nil)
    }
    
    func test_updateMasked_shouldSetRussianPrefix() throws {
        
        //given
        let value = ""
        let update = "89"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+7 9")
    }
    
    func test_updateMasked_shouldSetTurkeyPrefix() throws {
        
        //given
        let value = "+90"
        let update = "9"
        let range = NSRange(location: 3, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+90 9")
    }
    
    func test_updateMasked_shouldFilterLetter() throws {
        
        //given
        let value = "+7 925"
        let update = "a"
        let range = NSRange(location: 6, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldAppendDigit() throws {
        
        //given
        let value = "+7 925"
        let update = "5"
        let location = 6
        let range = NSRange(location: location, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(value.count, location)
        XCTAssertEqual(updated, "+7 925-5")
    }
    
    func test_updateMasked_shouldNotAppendSpace() throws {
        
        //given
        let value = "+374"
        let update = " "
        let location = 4
        let range = NSRange(location: location, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(value.count, location)
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldUpdateNilValue() throws {
        
        //given
        let value: String? = nil
        let update = "3"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldNotChangeNilValue_onEmptyUpdate() throws {
        
        //given
        let value: String? = nil
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, nil)
    }
    
    func test_updateMasked_shouldUpdateNilValue_onNonEmptyUpdate() throws {
        
        //given
        let value: String? = nil
        let update = "7"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+7")
    }
    
    func test_updateMasked_shouldNotInsertAtFirst_onLengthEqualToLimit() throws {
        
        //given
        let value = "+7 925 279-86-13"
        let update = "8"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldEnterInMiddleRange() throws {
        
        //given
        let value = "+7 925 279-86-13"
        let update = "8"
        let range = NSRange(location: 3, length: 1)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+7 8252798613")
    }
    
    func test_updateMasked_shouldFormatArmenianCountryCode_onEmptyUpdate() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 2, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldNotLimitResult_onNilLimit() throws {
        
        //given
        let value = "+7 925 279-86-1"
        let update = "3"
        let range = NSRange(location: 15, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, limit: limit)
        
        XCTAssertEqual(updated, "+7 925 279-86-13")
    }
    
    func test_shouldNotCompletearmenianCountryCodes_onPartialCode() throws {
        
        //given
        let value = "+37"
        let update = "3"
        let range = NSRange(location: 3, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+373")
    }
    
    func test_shouldNotCompleteturkeyCountryCodes_onPartialCode() throws {
        
        //given
        let value = "+9"
        let update = "1"
        let range = NSRange(location: 2, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+91")
    }
    
    func test_updateMasked_shouldCompleteArmenianCountryCode() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: nil)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_init_shouldSetReplaceTorussianCountryCodes_onContacts() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(.contacts)
        
        // then
        XCTAssertEqual(viewModel.countryCodeReplaces, .russian)
    }
    
    func test_init_shouldSetReplaceToFilterSymbols_onContacts() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(.contacts)
        
        // then
        XCTAssertEqual(viewModel.filterSymbols, .defaultFilterSymbols)
    }
    
    func test_init_shouldSetReplaceToRussian_onGeneralPhone() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(style: .general, placeHolder: .phone)
        
        // then
        XCTAssertEqual(viewModel.countryCodeReplaces, .russian)
    }
    
    func test_init_shouldSetReplaceToDefault_onAbroadPhone() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(style: .abroad, placeHolder: .phone)
        
        // then
        XCTAssertEqual(viewModel.filterSymbols, .defaultFilterSymbols)
    }
    
    // MARK: Complete Country Code Tests
    
    func test_init_shouldSetReplace_RussianDigits() throws {
        
        //given
        let value: String = "8 (925) 279 86 13"

        // when
        let updated = replaceCountryCode(phone: value, replaceDigits: .russian)
        
        // then
        XCTAssertEqual(updated, "79252798613")
    }
    
    func test_init_shouldSetNotReplace_TurkeyDigits() throws {
        
        //given
        let value = "90 921"
        
        // when
        let updated = replaceCountryCode(phone: value, replaceDigits: .russian)
        
        // then
        XCTAssertEqual(updated, "90921")
    }
    
    func test_init_shouldSetReplace_TurkeyDigits_onFirst9() throws {
        
        //given
        let value = "91 921"
        
        // when
        let updated = replaceCountryCode(phone: value, replaceDigits: .russian)
        
        // then
        XCTAssertEqual(updated, "91921")
    }
    
    //MARK: Helper

    private func replaceCountryCode(phone: String, replaceDigits: [CountryCodeReplace]) -> String {
        
        TextViewPhoneNumberView.replaceDigits(phone: phone, countryCodeReplaces: replaceDigits)
    }
    
    private func updateMasked(value: String?, inRange: NSRange, update: String, countryCodeReplace: [CountryCodeReplace]? = .russian, phoneFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater(), filterSymbols: [Character]? = .defaultFilterSymbols, limit: Int? = nil) -> String? {
        
        TextViewPhoneNumberView.updateMasked(value: value, inRange: inRange, update: update, countryCodeReplaces: countryCodeReplace, phoneFormatter: phoneFormatter, filterSymbols: filterSymbols, limit: limit)
    }
}
