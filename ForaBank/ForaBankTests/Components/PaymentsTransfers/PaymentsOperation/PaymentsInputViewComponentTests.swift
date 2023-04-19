//
//  PaymentsInputViewComponentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.04.2023.
//

@testable import ForaBank
import XCTest

// TODO: finish with tests coverage
final class PaymentsInputViewComponentTests: XCTestCase {

    func test_init_shouldSetValues_onEmpty() {
        
        let sut = makeSUT(initialValue: "")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.$isEditing)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(warningSpy.values, [nil])
        XCTAssertEqual(isEditingSpy.values, [false, false])
    }
        
    func test_init_shouldSetValues_onNonEmpty() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.$isEditing)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(warningSpy.values, [nil])
        XCTAssertEqual(isEditingSpy.values, [false, false])
    }
        
    func test_shouldChangeValues_onTextViewDidBeginEditing() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.$isEditing)
        
        sut.textField.textViewDidBeginEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, ["abcde", "abcde",])
        XCTAssertEqual(titleSpy.values, [nil, "Enter message"])
        XCTAssertEqual(warningSpy.values, [nil, nil])
        XCTAssertEqual(isEditingSpy.values, [
            false, false, true
        ])
    }
        
    func test_value_shouldChangeToValue_onNonEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        sut.textField.setText(to: "ABC")
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde", "ABC"])
    }
    
    func test_isEditing_should________onNonEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let isEditingSpy = ValueSpy(sut.textField.$isEditing)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, false,
        ])
                
        sut.textField.textViewDidBeginEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, false, true,
        ])
        
        sut.textField.setText(to: "ABC")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, false, true,
        ])

        sut.textField.textViewDidEndEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, false, true, false
        ])
    }
    
    func test_value_shouldChangeToNil_onEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        sut.textField.setText(to: "")
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde", ""])
    }
    
    func test_title_shouldChange_onNonEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let titleSpy = ValueSpy(sut.$title)
        
        XCTAssertEqual(titleSpy.values, [nil])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, [nil,])

        sut.textField.setText(to: "ABC")
        
        XCTAssertEqual(titleSpy.values, [nil])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, [nil, "Enter message"])
    }
    
    func test_title_shouldChangeToNil_onEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let titleSpy = ValueSpy(sut.$title)
        
        XCTAssertEqual(titleSpy.values, [nil])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, [nil])

        sut.textField.setText(to: "")
        
        XCTAssertEqual(titleSpy.values, [nil])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, [nil, "Enter message"])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialValue: String,
        validator: Payments.Validation.RulesSystem = .limit3or5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsInputView.ViewModel {
        
        let parameterInput = Payments.ParameterInput(
            .init(id: "1", value: initialValue),
            title: "Enter message",
            validator: validator
        )
        let sut = PaymentsInputView.ViewModel(with: parameterInput)

        trackForMemoryLeaks(sut)
        
        return sut
    }
}

private extension Payments.Validation.RulesSystem {
    
    static let limit3or5: Payments.Validation.RulesSystem = .init(
        rules: [
            Payments.Validation.LengthLimitsRule.limit3or5
        ]
    )
}

private extension Payments.Validation.LengthLimitsRule {
    
    static let limit3or5: Payments.Validation.LengthLimitsRule = .init(
        lengthLimits: [3, 5],
        actions: [.post: .warning("value lenght 3 or 5")]
    )
}
