//
//  UpdateMaskedTransformerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 23.05.2023.
//

@testable import Vortex
import TextFieldComponent
import XCTest

/// - Note: this test copies `TextFieldPhoneNumberViewComponentsTests`
/// to make sure that `Transformers.phoneKit` provides the same functionality.
final class UpdateMaskedTransformerTests: XCTestCase {
    
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
        #warning("reducer and transformer do not speak in optional text - the assert is different in original `test_updateMasked_shouldRemoveSymbol_onDelete`: XCTAssertEqual(updated, nil)")
        XCTAssertEqual(updated, "")
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
    
    func test_updateMasked_shouldSetTurkeyPrefix_typeAbroad() throws {
        
        //given
        let value = "+90"
        let update = "9"
        let range = NSRange(location: 3, length: 0)
        
        // when
        let updated = updateMasked(
            value: value,
            inRange: range,
            update: update,
            countryCodeReplace: .russian)
        
        // then
        XCTAssertEqual(updated, "+90 9")
    }
    
    func test_updateMasked_shouldSetTurkeyPrefix_typeOther() throws {
        
        //given
        let value = "+90"
        let update = "9"
        let range = NSRange(location: 3, length: 0)
        
        // when
        let updated = updateMasked(
            value: value,
            inRange: range,
            update: update,
            countryCodeReplace: .russian)
        
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
        XCTAssertEqual(updated, "+7 925 5")
    }
    
    func test_updateMasked_shouldNotAppendSpace_typeAbroad() throws {
        
        //given
        let value = "+3"
        let update = " "
        let location = 2
        let range = NSRange(location: location, length: 0)
        
        // when
        let updated = updateMasked(
            value: value,
            inRange: range,
            update: update,
            countryCodeReplace: .russian)
        
        XCTAssertEqual(value.count, location)
        XCTAssertEqual(updated, value)
    }
    
    func test_updateMasked_shouldUpdateNilValue_typeOther() throws {
        
        //given
        let value: String? = nil
        let update = "3"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(
            value: value,
            inRange: range,
            update: update,
            countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldNotChangeNilValue_onEmptyUpdate() throws {
        
        //given
        let value: String? = nil
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
#warning("reducer and transformer do not speak in optional text - the assert is different in original `test_updateMasked_shouldNotChangeNilValue_onEmptyUpdate`: XCTAssertEqual(updated, nil)")
        XCTAssertEqual(updated, "")
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
            // TODO: скорректировать алгоритм подстановки!!!
       // XCTAssertNoDiff(updated, "+7 925 279-86-13")
    }
    
    func test_updateMasked_shouldEnterInMiddleRange() throws {
        
        //given
        let value = "+7 925 279-86-13"
        let update = "8"
        let range = NSRange(location: 3, length: 1)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        XCTAssertEqual(updated, "+7 825 279-86-13")
    }
    
    func test_updateMasked_shouldFormatArmenianCountryCode_onEmptyUpdate_typeAbroad() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 2, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian)
        
        #warning("assertion differs from original test `test_updateMasked_shouldFormatArmenianCountryCode_onEmptyUpdate`: XCTAssertEqual(updated, \"+(3\")")
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldFormatArmenianCountryCode_onEmptyUpdate_typeOther() throws {
        
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
    
    func test_shouldNotCompletearmenianCountryCodes_onPartialCode_typeAbroad() throws {
        
        //given
        let value = "+37"
        let update = "3"
        let range = NSRange(location: 3, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+373")
    }
    
    func test_shouldNotCompletearmenianCountryCodes_onPartialCode_typeOther() throws {
        
        //given
        let value = "+37"
        let update = "3"
        let range = NSRange(location: 3, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+373")
    }
    
    func test_shouldNotCompleteturkeyCountryCodes_onPartialCode_typeAbroad() throws {
        
        //given
        let value = "+9"
        let update = "1"
        let range = NSRange(location: 2, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+91")
    }
    
    func test_shouldNotCompleteturkeyCountryCodes_onPartialCode_typeOther() throws {
        
        //given
        let value = "+9"
        let update = "1"
        let range = NSRange(location: 2, length: 0)
        let limit: Int? = nil
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: limit)
        
        XCTAssertEqual(updated, "+91")
    }
    
    func test_updateMasked_shouldCompleteArmenianCountryCode_typeAbroad() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: nil)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldCompleteArmenianCountryCode_typeOther() throws {
        
        //given
        let value = "+3"
        let update = ""
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: nil)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldCompleteArmenianCountryCode2_typeAbroad() throws {
        
        //given
        let value = ""
        let update = "3"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: nil)
        
        XCTAssertEqual(updated, "+3")
    }
    
    func test_updateMasked_shouldCompleteArmenianCountryCode2_typeOther() throws {
        
        //given
        let value = ""
        let update = "3"
        let range = NSRange(location: 0, length: 0)
        
        // when
        let updated = updateMasked(value: value, inRange: range, update: update, countryCodeReplace: .russian, limit: nil)
        
        XCTAssertEqual(updated, "+3")
    }
    
    // MARK: Helpers
    
    /// resembles `TextFieldPhoneNumberViewComponentsTests.swift`
    func updateMasked(
        value: String?,
        inRange range: NSRange,
        update: String,
        countryCodeReplace: [CountryCodeReplace]? = .russian,
        phoneFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater(),
        filterSymbols: [Character]? = .defaultFilterSymbols,
        limit: Int? = nil
    ) -> String? {
        
        let value = value ?? ""
        let placeholderText = "A placeholder"
        let state = TextFieldState.makeTextFieldState(
            text: value,
            cursorPosition: value.count,
            placeholderText: placeholderText
        )
        let action: TextFieldAction = .changeText(update, in: range)
        let substitutions: [CountryCodeSubstitution] = countryCodeReplace?.map(\.substitution) ?? []
        
        let transformer = Transformers.phoneKit(
            filterSymbols: filterSymbols ?? [],
            substitutions: substitutions,
            limit: limit
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
        )
        
        let newState = try? reducer.reduce(state, with: action)
        
        return newState?.text
    }
}
