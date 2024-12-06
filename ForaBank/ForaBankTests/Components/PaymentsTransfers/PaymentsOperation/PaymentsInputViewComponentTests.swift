//
//  PaymentsInputViewComponentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.04.2023.
//

import Combine
@testable import ForaBank
import XCTest

// TODO: finish with tests coverage
final class PaymentsInputViewComponentTests: XCTestCase {

    func test_init_shouldSetValues_onEmpty() {
        
        let sut = makeSUT(initialValue: "")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, [nil])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(warningSpy.values, [nil])
        XCTAssertEqual(isEditingSpy.values, [false])
    }
    
    func test_init_shouldSetValues_onNil() {
        
        let sut = makeSUT(initialValue: nil)
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, [nil])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(warningSpy.values, [nil])
        XCTAssertEqual(isEditingSpy.values, [false])
    }
        
    func test_init_shouldSetValues_onNonEmpty() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])
        XCTAssertEqual(titleSpy.values, ["Enter message"])
        XCTAssertEqual(warningSpy.values, [nil])
        XCTAssertEqual(isEditingSpy.values, [false])
    }
        
    func test_shouldChangeValues_onTextViewDidBeginEditing_onInitialValueEmpty() {
        
        let sut = makeSUT(initialValue: nil)
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        sut.textField.startEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, [nil, nil])
        XCTAssertEqual(titleSpy.values, [nil, "Enter message"])
        XCTAssertEqual(warningSpy.values, [nil, nil])
        XCTAssertEqual(isEditingSpy.values, [
            false, true
        ])
    }
    
    func test_shouldChangeValues_onTextViewDidBeginEditing() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let warningSpy = ValueSpy(sut.$warning)
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        sut.textField.startEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(currentValueSpy.values, ["abcde", "abcde"])
        XCTAssertEqual(titleSpy.values, ["Enter message", "Enter message"])
        XCTAssertEqual(warningSpy.values, [nil, nil])
        XCTAssertEqual(isEditingSpy.values, [
            false, true
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
        let isEditingSpy = ValueSpy(sut.textField.isEditing())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false,
        ])
                
        sut.textField.startEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, true,
        ])
        
        sut.textField.setText(to: "ABC")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, true, true
        ])

        sut.textField.finishEditing()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(isEditingSpy.values, [
            false, true, true, false
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
        XCTAssertEqual(currentValueSpy.values, ["abcde", nil])
    }
    
    func test_value_shouldChangeToNil_onNilTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        sut.textField.setText(to: nil)
        
        XCTAssertEqual(currentValueSpy.values, ["abcde"])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(currentValueSpy.values, ["abcde", nil])
    }
    
    func test_title_shouldNotChange_onNonEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let titleSpy = ValueSpy(sut.$title)
        
        XCTAssertEqual(titleSpy.values, ["Enter message"])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, ["Enter message"])

        sut.textField.setText(to: "ABC")
        
        XCTAssertEqual(titleSpy.values, ["Enter message"])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, ["Enter message", "Enter message"])
    }
    
    func test_title_shouldChangeToNil_onEmptyTextFiledInput() {
        
        let sut = makeSUT(initialValue: "abcde")
        let titleSpy = ValueSpy(sut.$title)
        
        XCTAssertEqual(titleSpy.values, ["Enter message"])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, ["Enter message"])

        sut.textField.setText(to: "")
        
        XCTAssertEqual(titleSpy.values, ["Enter message"])

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(titleSpy.values, ["Enter message", nil])
    }
    
    func test_updateSource_shouldNotSetAdditionalButtonOnNilHint() {
        
        let noHintParameterInput = anyParameterInput(hint: nil)
        let sut = makeSUT(initialValue: nil)
        let spy = ValueSpy(sut.$additionalButton.map(\.isPresent))
        XCTAssertNoDiff(spy.values, [false])
        
        sut.update(source: noHintParameterInput)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [false, false])
    }
    
    func test_updateSource_shouldSetAdditionalButtonWithHint() {
        
        let parameterInputWithHint = anyParameterInput(
            hint: anyInputHint()
        )
        let sut = makeSUT(initialValue: nil)
        let spy = ValueSpy(sut.$additionalButton.map(\.isPresent))
        XCTAssertNoDiff(spy.values, [false])
        
        sut.update(source: parameterInputWithHint)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [false, true])
    }
    
    func test_updateSource_shouldSetAdditionalButtonActionToShowHint() {
        
        let hintTitle = "Hint Title"
        let parameterInputWithHint = anyParameterInput(
            hint: anyInputHint(title: hintTitle)
        )
        let sut = makeSUT(initialValue: nil)
        let spy = ValueSpy(sut.showHintTitlePublisher)
        XCTAssertNoDiff(spy.values, [])
        
        sut.update(source: parameterInputWithHint)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        sut.additionalButton?.action()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [hintTitle])
    }
    
    func test_textField_editing_shouldSetCursorAtExpectedPosition() {
        
        let sut = makeSUT(initialValue: nil)
        let spy = ValueSpy(sut.textField.$state)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter message"),
        ])
        
        sut.textField.startEditing()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter message"),
            .editing(.init("", cursorAt: 0)),
        ])
        
        sut.textField.insert("abcdf", atCursor: 0)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter message"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("abcdf", cursorAt: 5)),
        ])

        sut.textField.insert("-", atCursor: 3)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)

        XCTAssertNoDiff(spy.values, [
            .placeholder("Enter message"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("abcdf", cursorAt: 5)),
            .editing(.init("abc-df", cursorAt: 4)),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialValue: String?,
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

        trackForMemoryLeaks(sut, file: file, line: line)
        
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

private func anyParameterInput(
    value: String? = nil,
    hint: Payments.ParameterInput.Hint? = nil
) -> Payments.ParameterInput {
    
    .init(
        .init(id: "input", value: value),
        title: "Title",
        hint: hint,
        validator: .anyValue
    )
}

private func anyInputHint(
    title: String = UUID().uuidString,
    subtitle: String = UUID().uuidString,
    icon: ImageData = .empty,
    hints: [Payments.ParameterInput.Hint.Content] = [anyInputHintContent()]
) -> Payments.ParameterInput.Hint {
    
    .init(
        title: title,
        subtitle: subtitle,
        icon: icon,
        hints: hints
    )
}

private func anyInputHintContent(
    title: String = UUID().uuidString,
    description: String = UUID().uuidString
) -> Payments.ParameterInput.Hint.Content {
    
    .init(title: title, description: description)
}

private extension PaymentsInputView.ViewModel.ButtonViewModel? {
    
    var isPresent: Bool { self != nil }
}

private extension PaymentsInputView.ViewModel {
    
    var showHintTitlePublisher: AnyPublisher<String, Never> {
        
        action
            .compactMap { $0 as? PaymentsParameterViewModelAction.Hint.Show }
            .map(\.viewModel.header.title)
            .eraseToAnyPublisher()
    }
}
