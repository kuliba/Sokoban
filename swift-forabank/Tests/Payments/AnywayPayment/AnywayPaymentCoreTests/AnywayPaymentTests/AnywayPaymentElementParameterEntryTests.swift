//
//  AnywayPaymentElementParameterEntryTests.swift
//
//
//  Created by Igor Malyarov on 18.04.2024.
//

extension AnywayPayment.Element.Parameter {
    
    var entry: Entry? {
        
        switch uiAttributes.viewType {
        case .constant:
            switch uiAttributes.dataType {
            case .number, .string:
                return field.value.map { .nonEditable(.string($0.rawValue)) }
                
            case let .pairs(pair, _):
                return .nonEditable(.pair(key: pair.key, value: pair.value))
            }
            
        case .input:
            switch uiAttributes.dataType {
            case .number:
                switch uiAttributes.type {
                case .input:
                    return .numberInput(id: field.id, value: field.value)
                    
                case .maskList, .select:
                    return nil
                }
                
            case let .pairs(pair, pairs):
                switch uiAttributes.type {
                case .input:
                    return nil
                    
                case .maskList:
                    return .maskList(pair, pairs)
                    
                case .select:
                    return .select(pair, pairs)
                }
                
            case .string:
                switch uiAttributes.type {
                case .input:
                    return .textInput(id: field.id, value: field.value)
                    
                case .maskList, .select:
                    return nil
                }
            }
            
        case .output:
            switch uiAttributes.dataType {
            case .number, .string:
                return field.value.map { .hidden($0.rawValue) }
                
            case let .pairs(pair, _):
                return .hidden(pair.key)
            }
        }
    }
    
    enum Entry: Equatable {
        
        case hidden(String)
        case maskList(Pair, [Pair])
        case nonEditable(Field)
        case numberInput(id: ID, value: Value?)
        case select(Pair, [Pair])
        case textInput(id: ID, value: Value?)
    }
}

extension AnywayPayment.Element.Parameter.Entry {
    
    enum Field: Equatable {
        
        case string(String)
        case pair(key: String, value: String)
    }
    
    typealias ID = AnywayPayment.Element.Parameter.Field.ID
    typealias Value = AnywayPayment.Element.Parameter.Field.Value
    
    typealias Pair = AnywayPayment.Element.Parameter.UIAttributes.DataType.Pair
}

import AnywayPaymentCore
import XCTest

final class AnywayPaymentElementParameterEntryTests: XCTestCase {
    
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
    
    private typealias DataType = AnywayPayment.Element.Parameter.UIAttributes.DataType
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
        value: String? = nil,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType,
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType
    ) -> AnywayPayment.Element.Parameter {
        
        makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
                id: id,
                value: value
            ),
            uiAttributes: makeUIAttributes(
                type: type,
                dataType: dataType,
                viewType: viewType
            )
        )
    }
    
    private func makeUIAttributes(
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType,
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType
    ) -> AnywayPayment.Element.Parameter.UIAttributes {
        
        makeAnywayPaymentElementParameterUIAttributes(
            dataType: dataType,
            type: type,
            viewType: viewType
        )
    }
    
    private func maskList(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .maskList(pair, [pair] + pairs)
    }
    
    private func nonEditable(
        _ string: String
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .nonEditable(.string(string))
    }
    
    private func nonEditable(
        _ key: String,
        _ value: String
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .nonEditable(.pair(key: key, value: value))
    }
    
    private func numberInput(
        _ id: AnywayPayment.Element.Parameter.Entry.ID,
        _ value: AnywayPayment.Element.Parameter.Entry.Value?
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .numberInput(id: id, value: value)
    }
    
    private func select(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .select(pair, [pair] + pairs)
    }
    
    private func textInput(
        _ id: AnywayPayment.Element.Parameter.Entry.ID,
        _ value: AnywayPayment.Element.Parameter.Entry.Value?
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .textInput(id: id, value: value)
    }
}
