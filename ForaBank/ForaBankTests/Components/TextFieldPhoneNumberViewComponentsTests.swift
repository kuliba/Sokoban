//
//  TextFieldPhoneNumberViewComponentsTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 26.10.2022.
//

import XCTest
@testable import ForaBank

final class TextFieldPhoneNumberViewComponentsTests: XCTestCase {
    
    func test_updateMasked_shouldEnterFirstDigit() throws {
        
        //given
        let value = ""
        let update = "7"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        // then
        XCTAssertEqual(updated, "+7")
    }
    
    func test_updateMasked_shouldEnterFirstLetter() throws {
        
        //given
        let value = ""
        let update = "п"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        // then
        XCTAssertEqual(updated, "")
    }
    
    func test_updateMasked_shouldRemoveSymbol() throws {
        
        //given
        let value = "+7"
        let update = ""
        let range = NSRange(location: 1, length: 1)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        // then
        XCTAssertEqual(updated, nil)
    }
    
    func test_updateMasked_shouldSetReplaceDigit() throws {
        
        //given
        let value = ""
        let update = "8"
        let range = NSRange(location: 0, length: 0)

        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        // then
        XCTAssertEqual(updated, "+7")
    }
    
    func test_updateMasked_shouldSetTurkeyPrefix() throws {
        
        //given
        let value = "+90"
        let update = "9"
        let range = NSRange(location: 3, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .turkeyFirstDigits)
        
        // then
        XCTAssertEqual(updated, "+90 9")
    }
    
    func test_updateMasked_shouldFilteredLetter() throws {
        
        //given
        let value = "+7 925"
        let update = "a"
        let range = NSRange(location: 6, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldEnterDigit() throws {
        
        //given
        let value = "+7 925"
        let update = "5"
        let range = NSRange(location: 6, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        XCTAssertEqual(updated, "+7 925-5")
    }
    
    func test_updateMasked_shouldSetUpdateNotEmpty() throws {
        
        //given
        let value = "+374"
        let update = " "
        let range = NSRange(location: 4, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldSetValueNil() throws {
        
        //given
        let value: String? = nil
        let update = "3"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, "3")
    }
    
    func test_updateMasked_shouldSetValueNil_and_UpdateEmpty() throws {
        
        //given
        let value: String? = nil
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, nil)
    }
    
    func test_updateMasked_shouldSetValueNil_updateNotEmpty() throws {
        
        //given
        let value: String? = nil
        let update = "7"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, "7")
    }
    
    func test_updateMasked_shouldSetNotValidLenght() throws {
        
        //given
        let value = "+7 925 279-86-13"
        let update = "8"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldEnterInMiddleRange() throws {
        
        //given
        let value = "+7 925 279-86-13"
        let update = "8"
        let range = NSRange(location: 3, length: 1)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .russianFirstDigits)
        
        XCTAssertEqual(updated, "+7 8252798613")
    }
    
    func test_updateMasked_shouldSetUpdateEmpty() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 2, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits)
        
        XCTAssertEqual(updated, "+(3")
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
    
    func test_updateMasked_shouldSetRange_0_0() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, firstDigitReplace: .armenianFirstDigits, limit: nil)
        
        XCTAssertEqual(updated, "+374")
    }
    
    func test_init_shouldSetReplaceToRussianFirstDigits_onContacts() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(.contacts)
        
        // then
        XCTAssertEqual(viewModel.firstDigitReplaceList, .russianFirstDigits)
    }
    
    func test_init_shouldSetReplaceToFilterSymbols_onContacts() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(.contacts)
        
        // then
        XCTAssertEqual(viewModel.filterSymbols, .defaultfilterSymbols)
    }
    
    func test_init_shouldSetReplaceToRussian_onGeneralPhone() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(style: .general, placeHolder: .phone)
        
        // then
        XCTAssertEqual(viewModel.firstDigitReplaceList, .russianFirstDigits)
    }
    
    func test_init_shouldSetReplaceToDefault_onAbroadPhone() throws {
        
        //given
        let viewModel = TextViewPhoneNumberView.ViewModel(style: .abroad, placeHolder: .phone)
        
        // then
        XCTAssertEqual(viewModel.filterSymbols, .defaultfilterSymbols)
    }
    
    //MARK: Test's Replace Digits
    
    func test_init_shouldSetReplace_RussianDigits() throws {
        
        //given
        let value: String = "8 (925) 279 86 13"

        // when
        let updated = replaceDigits(phone: value, replaceDigits: .russianFirstDigits)
        
        // then
        XCTAssertEqual(updated, "7 (925) 279 86 13")
    }
    
    func test_init_shouldSetNotReplace_TurkeyDigits() throws {
        
        //given
        let value = "90 921"
        
        // when
        let updated = replaceDigits(phone: value, replaceDigits: .turkeyFirstDigits)
        
        // then
        XCTAssertEqual(updated, value)
    }
    
    func test_init_shouldSetReplace_TurkeyDigits_onFirst9() throws {
        
        //given
        let value = "91 921"
        
        // when
        let updated = replaceDigits(phone: value, replaceDigits: .turkeyFirstDigits)
        
        // then
        XCTAssertEqual(updated, "901 921")
    }
    
    //MARK: Helper

    private func replaceDigits(phone: String, replaceDigits: [TextViewPhoneNumberView.ViewModel.Replace]) -> String {
        
        TextViewPhoneNumberView.replaceDigits(phone: phone, replaceDigits: replaceDigits)
    }
    
    private func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [TextViewPhoneNumberView.ViewModel.Replace]? = .russianFirstDigits, phoneFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater(), filterSymbols: [Character]? = .defaultfilterSymbols, limit: Int? = nil) -> String? {
        
        TextViewPhoneNumberView.updateMasked(value: value, inRange: inRange, update: update, firstDigitReplace: firstDigitReplace, phoneFormatter: phoneFormatter, filterSymbols: filterSymbols, limit: limit)
    }
}
