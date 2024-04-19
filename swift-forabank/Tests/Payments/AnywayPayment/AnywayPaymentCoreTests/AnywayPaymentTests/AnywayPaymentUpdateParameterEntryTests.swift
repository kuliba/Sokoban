//
//  AnywayPaymentUpdateParameterEntryTests.swift
//
//
//  Created by Igor Malyarov on 18.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentUpdateParameterEntryTests: XCTestCase {
    
    // MARK: - constant viewType
    
    // MARK: number dataType
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .constant,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("12345"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .constant,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("12345"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .constant,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("12345"))
    }
    
    // MARK: string dataType
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_constantViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("abcd"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("abcd"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValue_constantViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("abcd"))
    }
    
    // MARK: pair dataType
    
    func test_entry_shouldDeliverNonEditablePairValueOnNilValue_constantViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValueOnNilValue_constantViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValueOnNilValue_constantViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValue_constantViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValue_constantViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValue_constantViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    // MARK: - output viewType
    
    // MARK: number dataType
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .output,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("12345"))
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .output,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("12345"))
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .output,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("12345"))
    }
    
    // MARK: string dataType
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_outputViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("abcd"))
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("abcd"))
    }
    
    func test_entry_shouldDeliverHiddenStringValue_outputViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("abcd"))
    }
    
    // MARK: pair dataType
    
    func test_entry_shouldDeliverHiddenPairValueOnNilValue_outputViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValueOnNilValue_outputViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValueOnNilValue_outputViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValue_outputViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValue_outputViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValue_outputViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    // MARK: - input viewType
    
    // MARK: number dataType
    
    func test_entry_shouldDeliverNumberInputWithNilValueOnNilValue_inputViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            id: "a",
            value: nil,
            viewType: .input,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, numberInput("a", nil))
    }
    
    func test_entry_shouldDeliverNilOnNilValue_inputViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_inputViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNumberInputWithValue_inputViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            id: "abc",
            value: "12345",
            viewType: .input,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, numberInput("abc", "12345"))
    }
    
    func test_entry_shouldDeliverNil_inputViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .input,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNil_inputViewType_numberDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .input,
            dataType: .number,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    // MARK: string dataType
    
    func test_entry_shouldDeliverTextInputWithNilValueOnNilValue_inputViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            id: "abc",
            value: nil,
            viewType: .input,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, textInput("abc", nil))
    }
    
    func test_entry_shouldDeliverNilOnNilValue_inputViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNilOnNilValue_inputViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverTextInputWithValue_inputViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            id: "abc",
            value: "abcd",
            viewType: .input,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, textInput("abc", "abcd"))
    }
    
    func test_entry_shouldDeliverNil_inputViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .input,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverNil_inputViewType_stringDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .input,
            dataType: .string,
            type: .maskList
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    // MARK: pair dataType
    
    func test_entry_shouldDeliverNilOnNilValue_inputViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverSelectWithPairsOnNilValue_inputViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, select(("b", "B"), ("a", "A")))
    }
    
    func test_entry_shouldDeliverMaskListWithPairsOnNilValue_inputViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: nil,
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, maskList(("b", "B"), ("a", "A")))
    }
    
    func test_entry_shouldDeliverNil_inputViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNil(parameter.entry)
    }
    
    func test_entry_shouldDeliverSelectWithPairs_inputViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, select(("b", "B"), ("a", "A")))
    }
    
    func test_entry_shouldDeliverMaskListWithPairs_inputViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .input,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, maskList(("b", "B"), ("a", "A")))
    }
    
    // MARK: - Helpers
    
    private typealias DataType = AnywayPaymentUpdate.Parameter.UIAttributes.DataType
    private typealias Entry = AnywayPaymentUpdate.Parameter.Entry
    private typealias FieldType = AnywayPaymentUpdate.Parameter.UIAttributes.FieldType
    private typealias ViewType = AnywayPaymentUpdate.Parameter.UIAttributes.ViewType
    private typealias Pair = (key: String, value: String)

    
    private func makePairsDataType(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> DataType {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .pairs(pair, [pair] + pairs)
    }
    
    private func makeParameter(
        id: String = anyMessage(),
        value content: String? = nil,
        viewType: ViewType,
        dataType: DataType,
        type: FieldType
    ) -> AnywayPaymentUpdate.Parameter {
        
        makeAnywayPaymentUpdateParameter(
            field: makeAnywayPaymentUpdateParameterField(
                content: content,
                id: id
            ),
            uiAttributes: makeUIAttributes(
                type: type,
                dataType: dataType,
                viewType: viewType
            )
        )
    }
    
    private func makeUIAttributes(
        type: FieldType,
        dataType: DataType,
        viewType: ViewType
    ) -> AnywayPaymentUpdate.Parameter.UIAttributes {
        
        makeAnywayPaymentUpdateParameterUIAttributes(
            dataType: dataType,
            type: type,
            viewType: viewType
        )
    }
    
    private func maskList(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> Entry {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .maskList(pair, [pair] + pairs)
    }
    
    private func nonEditable(
        _ string: String
    ) -> Entry {
        
        .nonEditable(.string(string))
    }
    
    private func nonEditable(
        _ key: String,
        _ value: String
    ) -> Entry {
        
        .nonEditable(.pair(key: key, value: value))
    }
    
    private func numberInput(
        _ id: Entry.ID,
        _ value: Entry.Value?
    ) -> Entry {
        
        .numberInput(id: id, value: value)
    }
    
    private func select(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> Entry {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .select(pair, [pair] + pairs)
    }
    
    private func textInput(
        _ id: Entry.ID,
        _ value: Entry.Value?
    ) -> Entry {
        
        .textInput(id: id, value: value)
    }
}
