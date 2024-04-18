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
            return nil
            
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
        case nonEditable(Field)
    }
}

extension AnywayPayment.Element.Parameter.Entry {
    
    enum Field: Equatable {
        
        case string(String)
        case pair(key: String, value: String)
    }
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
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .constant,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("12345"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .constant,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("12345"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_numberDateType_maskListType() {
        
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
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("abcd"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("abcd"))
    }
    
    func test_entry_shouldDeliverNonEditableStringValueOn_constantViewType_stringDateType_maskListType() {
        
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
    
    func test_entry_shouldDeliverNonEditablePairValueOn_constantViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValueOn_constantViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .constant,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, nonEditable("b", "B"))
    }
    
    func test_entry_shouldDeliverNonEditablePairValueOn_constantViewType_pairsDateType_maskListType() {
        
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
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_numberDateType_inputType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .output,
            dataType: .number,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("12345"))
    }
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_numberDateType_selectType() {
        
        let parameter = makeParameter(
            value: "12345",
            viewType: .output,
            dataType: .number,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("12345"))
    }
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_numberDateType_maskListType() {
        
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
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_stringDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: .string,
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("abcd"))
    }
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_stringDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: .string,
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("abcd"))
    }
    
    func test_entry_shouldDeliverHiddenStringValueOn_outputViewType_stringDateType_maskListType() {
        
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
    
    func test_entry_shouldDeliverHiddenPairValueOn_outputViewType_pairsDateType_inputType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .input
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValueOn_outputViewType_pairsDateType_selectType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .select
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
    }
    
    func test_entry_shouldDeliverHiddenPairValueOn_outputViewType_pairsDateType_maskListType() {
        
        let parameter = makeParameter(
            value: "abcd",
            viewType: .output,
            dataType: makePairsDataType(("b", "B"), ("a", "A")),
            type: .maskList
        )
        
        XCTAssertNoDiff(parameter.entry, .hidden("b"))
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
        value: String? = nil,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType,
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType
    ) -> AnywayPayment.Element.Parameter {
        
        makeAnywayPaymentParameter(
            field: makeAnywayPaymentElementParameterField(
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
    
    func nonEditable(
        _ string: String
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .nonEditable(.string(string))
    }
    
    func nonEditable(
        _ key: String,
        _ value: String
    ) -> AnywayPayment.Element.Parameter.Entry {
        
        .nonEditable(.pair(key: key, value: value))
    }
}
