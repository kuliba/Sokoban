//
//  MaskChangingReducerTests.swift
//
//
//  Created by Igor Malyarov on 09.01.2025.
//

import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class BasicMaskBehaviorTests: MaskChangingReducerTests {
    
    func test_emptyMask() throws {
        
        let input = editing(.init("abc123"))
        let (_, sut) = makeSUT(maskPattern: "")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("abc123", cursorAt: 6)) )
    }
    
    func test_emptyMaskWithSpecialCharacters() throws {
        
        let text = "abc!@#123"
        let input = editing(.init(text))
        let (_, sut) = makeSUT(maskPattern: "")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init(text, cursorAt: 9)))
    }
    
    func test_noMask() throws {
        
        let text = "ABC123!@#"
        let input = editing(.init(text))
        let (_, sut) = makeSUT(maskPattern: "")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init(text, cursorAt: 9)))
    }
    
    func test_emptyInputWithMask() throws {
        
        let input = editing(.init(""))
        let (_, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("", cursorAt: 0)))
    }
    
    func test_whitespaceInInput() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("1 2 3") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("123", cursorAt: 3)))
    }
    
    func test_numericPlaceholderMismatch() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNNN")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("12x4") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("124", cursorAt: 3)))
    }
    
    func test_anyPlaceholderAndStaticMix() throws {
        
        let (state, sut) = makeSUT(maskPattern: "N_._N")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("1ABZ") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("1A.B", cursorAt: 4)))
    }
    
    func test_underscoreMaskAnyChars() throws {
        
        let (state, sut) = makeSUT(maskPattern: "_ _ _")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("ABC") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("A B C", cursorAt: 5)), "Expected cursor position after last inserted character")
    }
    
    func test_mixedMask() throws {
        
        let (state, sut) = makeSUT(maskPattern: "N_NN_")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("1x23y") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("1x23y", cursorAt: 5)))
    }
    
    func test_maskStopsAtNonDigit() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("12a") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("12", cursorAt: 2)))
    }
    
    func test_insertingIntoFullMask() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("123") },
            { try $0.insert("4") }
        )
        
        XCTAssertNoDiff(output.last, .editing(.init("123", cursorAt: 3)))
    }
}

final class ComplexEditingTests: MaskChangingReducerTests {
    
    func test_sequence() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN-___")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("12") },
            { try $0.insert("AB") },
            { try $0.insert("345") },
            { try $0.paste("xyz") },
            
            // If delete at cursor=0, do nothing, so the final is "123-AB"
            { st in
                do {
                    return try st.delete()
                } catch {
                    // fallback => do nothing => effectively .changeText("", in: zeroRange)
                    return .changeText("", in: .init(location: 0, length: 0))
                }
            }
        )
        
        // final => "123-AB"
        XCTAssertNoDiff(result.last, .editing(.init("123-AB", cursorAt: 6)))
    }
    
    func test_deletionAcrossSegments() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN-NNN")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("123456") },
            { try $0.delete() },
            { try $0.delete() }
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("123-4", cursorAt: 5)))
    }
    
    func test_insertionAndDeletionAcrossSegments() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN-NNN")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("123456") },
            { try $0.delete() }, // Deletes '6'
            { try $0.insert("9") } // Inserts '9' at the end
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("123-459", cursorAt: 7)))
    }
    
    func test_removeLastOverStatic() throws {
        
        let input = editing(.init("123-", cursorPosition: 4))
        let (_, sut) = makeSUT(maskPattern: "NNN-___")
        
        let output = try sut.reduce(input, with: .changeText("", in: .init(location: 3, length: 1)))
        
        XCTAssertNoDiff(output, .editing(.init("12", cursorPosition: 2)))
    }
    
    func test_undoRedo() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN-___")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("123") },
            { try $0.removeLast(3) },
            { try $0.removeLast(1) }
        )
        
        XCTAssertNoDiff(result.suffix(2), [
            .editing(.init("1", cursorAt: 1)),
            .editing(.empty)
        ])
    }
    
    func test_removeLastByOne() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN-___")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("12345") },
            { try $0.removeLast(1) },
            { try $0.removeLast(1) },
            { try $0.removeLast(1) },
            { try $0.removeLast(1) },
            { try $0.removeLast(1) }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter masked data"),
            .editing(.empty),
            .editing(.init("123-45", cursorAt: 6)),
            .editing(.init("123-4", cursorAt: 5)),
            .editing(.init("123-", cursorAt: 4)),
            .editing(.init("12", cursorAt: 2)),
            .editing(.init("1", cursorAt: 1)),
            .editing(.empty)
        ])
    }
}

final class FixedLengthMaskTests: MaskChangingReducerTests {
    
    func test_exact() throws {
        
        let input = editing(.init("ABCDEFGH"))
        let (_, sut) = makeSUT(maskPattern: "________")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("ABCDEFGH", cursorAt: 8)))
    }
    
    func test_shortFill() throws {
        
        let input = editing(.init("AB"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("AB", cursorAt: 2)))
    }
    
    func test_exactFill() throws {
        
        let input = editing(.init("1234"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("1234", cursorAt: 4)))
    }
    
    func test_overfill() throws {
        
        let input = editing(.init("ABCDE"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("ABCD", cursorAt: 4)))
    }
    
    func test_overfillWithSymbols() throws {
        
        let input = editing(.init("1234!@"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("1234", cursorAt: 4)))
    }
    
    func test_anyCharacters() throws {
        
        let (state, sut) = makeSUT(maskPattern: "____")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("Ab#") },
            { try $0.insert("cDe!") }
        )
        
        XCTAssertNoDiff(result[3], .editing(.init("Ab#c", cursorAt: 4)))
    }
    
    func test_withAlphanumeric() throws {
        
        let input = editing(.init("AB12"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("AB12", cursorAt: 4)))
    }
    
    func test_withWhitespace() throws {
        
        let input = editing(.init("AB C"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("ABC", cursorAt: 3)))
    }
    
    func test_fixedLengthMaskDeletion() throws {
        
        let input = editing(.init("ABCD"))
        let (_, sut) = makeSUT(maskPattern: "____")
        
        let output = try sut.reduce(input, with: input.removeLast())
        
        XCTAssertNoDiff(output, .editing(.init("ABC", cursorAt: 3)))
    }
}

final class NumericMaskTests: MaskChangingReducerTests {
    
    func test_shouldIgnoreSpecialCharacters() throws {
        
        let input = editing(.init("12@3!4"))
        let (_, sut) = makeSUT(maskPattern: "NNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("1234", cursorAt: 4)))
    }
    
    func test_partialFill() throws {
        
        let input = editing(.init("123"))
        let (_, sut) = makeSUT(maskPattern: "NNNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("123", cursorAt: 3)) )
    }
    
    func test_excessInput() throws {
        
        let input = editing(.init("12345"))
        let (_, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("123", cursorAt: 3)) )
    }
    
    func test_numericSequenceExactLength() throws {
        
        let input = editing(.init("12345"))
        let (_, sut) = makeSUT(maskPattern: "NNNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("12345", cursorAt: 5)))
    }
    
    func test_numericSequenceWithPrefix() throws {
        
        let input = editing(.init("+12345678901"))
        let (_, sut) = makeSUT(maskPattern: "+NNNNNNNNNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("+12345678901", cursorAt: 12)))
    }
    
    func test_numericSequenceOverfill() throws {
        
        let input = editing(.init("1234567"))
        let (_, sut) = makeSUT(maskPattern: "NNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("1234", cursorAt: 4)))
    }
    
    func test_shouldLimitDigits() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            // Insert a single digit
            { try $0.insert("1") },
            // Insert multiple digits, but the mask is only 3 digits
            { try $0.insert("2345") }
        )
        
        XCTAssertNoDiff(result.count, 4)
        XCTAssertNoDiff(result[0], .placeholder("Enter masked data"))
        XCTAssertNoDiff(result[1], .editing(.empty))
        XCTAssertNoDiff(result[2], .editing(.init("1", cursorAt: 1)))
        XCTAssertNoDiff(result[3], .editing(.init("123", cursorAt: 3)))
    }
    
    func test_shouldIgnoreNonDigit() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            // Insert a letter among digits
            { try $0.insert("1a2b3") }
        )
        
        XCTAssertNoDiff(result[0], .placeholder("Enter masked data"))
        XCTAssertNoDiff(result[1], .editing(.empty))
        XCTAssertNoDiff(result[2], .editing(.init("123", cursorAt: 3)))
    }
    
    func test_withLeadingZeros() throws {
        
        let input = editing(.init("00123"))
        let (_, sut) = makeSUT(maskPattern: "NNNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("00123", cursorAt: 5)))
    }
    
    func test_incrementalInsertion() throws {
        
        let (state, sut) = makeSUT(maskPattern: "NNN")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("1") },
            { try $0.insert("2") },
            { try $0.insert("3") }
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("123", cursorAt: 3)))
    }
    
    func test_insertionInMiddle() throws {
        
        let input = editing(.init("12", cursorPosition: 1))
        let (_, sut) = makeSUT(maskPattern: "NNN")
        
        let output = try sut.reduce(input, with: .changeText("3", in: .init(location: 1, length: 0)))
        
        XCTAssertNoDiff(output, .editing(.init("132", cursorAt: 2)))
    }
    
    func test_withLeadingZerosAndOverfill() throws {
        
        let input = editing(.init("001234"))
        let (_, sut) = makeSUT(maskPattern: "NNNN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("0012", cursorAt: 4)))
    }
}

final class PhoneNumberMaskTests: MaskChangingReducerTests {
    
    func test_standardPartial() throws {
        
        let (state, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("12") },
            { try $0.insert("34") }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter masked data"),
            editing(.empty),
            .editing(.init("+7(12", cursorAt: 5)),
            .editing(.init("+7(123)-4", cursorAt: 9))
        ])
    }
    
    func test_autoCorrection() throws {
        
        let (state, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.paste("12") },
            { try $0.insert("3") }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter masked data"),
            editing(.empty),
            .editing(.init("+7(12", cursorAt: 5)),
            .editing(.init("+7(123)-", cursorAt: 8)),
        ])
    }

    func test_shouldRejectInvalidSymbols() throws {
        
        let input = editing(.init("+7(12@)-456-78"))
        let (_, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("+7(12)-456-78", cursorAt: 13)))
    }
    
    func test_standard() throws {
        
        let input = editing(.init("+7(123)-456-78"))
        let (_, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("+7(123)-456-78", cursorAt: 13)))
    }
    
    func test_overfill() throws {
        
        let input = editing(.init("+7(999)-999-999"))
        let (_, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("+7(999)-999-99-99", cursorAt: 16)))
    }
    
    func test_shouldRejectLetters() throws {
        
        let input = editing(.init("+7(12a)-45b-6"))
        let (_, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("+7(12)-45-6", cursorAt: 11)))
    }
    
    func test_partialDeletion() throws {
        
        let (state, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("+7(123)-456-78") },
            { try $0.delete() }
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("+7(123)-456-7", cursorAt: 13)))
    }
    
    func test_multipleEdits_insertsAndDeletesAndReplaces() throws {
        
        let (state, sut) = makeSUT(maskPattern: "+7(___)-___-__-__")
        
        let result = try sut.reduce(
            state,
            actions:
                { _ in .startEditing },
            { try $0.insert("+7(12") },
            { try $0.insert("abc") },
            { try $0.insert("345678") },
            { try $0.delete() },
            { try $0.delete() },
            { try $0.insert("99") },
            { try $0.replace(from: 3, count: 3, with: "777") },
            { try $0.delete() }
        )
        
        // Steps per test expectation:
        XCTAssertNoDiff(result[0], .placeholder("Enter phone number"))
        XCTAssertNoDiff(result[1], .editing(.init("", cursorPosition: 0)))
        // +7(12
        XCTAssertNoDiff(result[2], .editing(.init("+7(12", cursorPosition: 5)))
        // insert "abc" => skip => remains +7(12
        XCTAssertNoDiff(result[3], .editing(.init("+7(12", cursorPosition: 5)))
        // insert "345678" => => +7(123)-456-78
        XCTAssertNoDiff(result[4], .editing(.init("+7(123)-456-78", cursorPosition: 14)))
        // delete => remove '8'
        XCTAssertNoDiff(result[5], .editing(.init("+7(123)-456-7", cursorPosition: 13)))
        // delete => remove '7'
        XCTAssertNoDiff(result[6], .editing(.init("+7(123)-456-", cursorPosition: 12)))
        // insert "99" => +7(123)-456-99
        XCTAssertNoDiff(result[7], .editing(.init("+7(123)-456-99", cursorPosition: 14)))
        // replace 3 digits from index=3 => => +7(777)-456-99
        XCTAssertNoDiff(result[8], .editing(.init("+7(777)-456-99", cursorPosition: 9)))
        // delete => +7(777)-456-9
        XCTAssertNoDiff(result[9], .editing(.init("+7(777)-456-9", cursorPosition: 13)))
    }
    
    func test_simulateRealEditingFlow() throws {
        
        let maskPattern = "+7(___)-___-__-__"
        let (state, sut) = makeSUT(maskPattern: maskPattern)
        
        let result = try sut.reduce(
            state,
            actions:
                { _ in .startEditing },
            { try $0.insert("9991112223") },
            { try $0.replace(from: 5, count: 3, with: "777") },
            { try $0.delete() },
            { try $0.delete() },
            { try $0.delete() },
            { try $0.insert("55") }
        )
        
        let final = result.last!
        
        switch final {
        case .editing(let textState):
            XCTAssertTrue(
                textState.text.hasSuffix("55"),
                "Final text: \(textState.text) doesn't end with 55"
            )
            XCTAssertLessThanOrEqual(textState.text.count, maskPattern.count)
        default:
            XCTFail("Expected final .editing state.")
        }
    }
}

final class PrefilledMaskTests: MaskChangingReducerTests {
    
    func test_partialFill() throws {
        
        let input = editing(.init("3086595000-123-45"))
        let (_, sut) = makeSUT(maskPattern: "3086595000-___-___-___")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("3086595000-123-45", cursorAt: 17)))
    }
    
    func test_overfill() throws {
        
        let input = editing(.init("abc-12-ABCDE-XYZP"))
        let (_, sut) = makeSUT(maskPattern: "abc-__-_____-___")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("abc-12-ABCDE-XYZ", cursorAt: 15)))
    }
    
    func test_withStaticText() throws {
        
        let (state, sut) = makeSUT(maskPattern: "abc-__-_____-___")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("12ABCDEXYZ") }
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("abc-12-ABCDE-XYZ", cursorAt: 16)))
    }
}

final class SegmentedMaskTests: MaskChangingReducerTests {
    
    func test_simple() throws {
        
        let input = editing(.init("ABCD"))
        let (_, sut) = makeSUT(maskPattern: "__-___")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("AB-CD", cursorAt: 5)))
    }
    
    func test_withStaticDelimiter() throws {
        
        let input = editing(.init("1234"))
        let (_, sut) = makeSUT(maskPattern: "NN-NN")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("12-34", cursorAt: 5)))
    }
    
    func test_partialFill() throws {
        
        let (state, sut) = makeSUT(maskPattern: "__-___")
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("ABCD") }
        )
        
        XCTAssertNoDiff(result.last, .editing(.init("AB-CD", cursorAt: 5)))
    }
    
    func test_full() throws {
        
        let input = editing(.init("ABCDXYZ"))
        let (_, sut) = makeSUT(maskPattern: "__-___-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("AB-CDX-YZ", cursorAt: 9)))
    }
    
    func test_preventsDelimiterDeletion() throws {
        
        let input = editing(.init("12-34"))
        let (_, sut) = makeSUT(maskPattern: "NN-NN")
        
        let output = try sut.reduce(input, with: input.removeLast())
        
        XCTAssertNoDiff(output, .editing(.init("12-3", cursorAt: 4)))
    }
    
    func test_shouldRejectInvalidCharacters() throws {
        
        let input = editing(.init("AB#CD"))
        let (_, sut) = makeSUT(maskPattern: "__-__")
        
        let output = try sut.reduce(input, with: input.insert(""))
        
        XCTAssertNoDiff(output, .editing(.init("AB-CD", cursorAt: 5)))
    }
}

class MaskChangingReducerTests: XCTestCase {
    
    // MARK: - Helpers
    
    typealias SUT = ChangingReducer
    typealias State = TextFieldState
    
    func makeSUT(
        state: TextFieldState? = nil,
        placeholderText: String = "Enter masked data",
        maskPattern pattern: String
    ) -> (
        state: TextFieldState,
        sut: SUT
    ) {
        let state = state ?? .init(placeholderText)
        
        let sut = SUT.mask(placeholderText: placeholderText, pattern: pattern)
        
        return (state, sut)
    }
    
    func editing(_ textState: TextState) -> State {
        
        return .editing(textState)
    }
}
