//
//  PaymentsCodeViewComponentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 12.04.2023.
//

import CombineSchedulers
@testable import ForaBank
@testable import TextFieldRegularComponent
import XCTest

final class PaymentsCodeViewComponentTests: XCTestCase {
    
    typealias CodeAction = PaymentsParameterViewModelAction.Code
    
    func test_init_shouldSetInitialValues_onNil() throws {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: nil,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let editingStateSpy = ValueSpy(sut.$editingState)
        let resendStateSpy = ValueSpy(sut.$resendState)
        let textFieldSpy = ValueSpy(sut.textField.$state)
        
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [nil])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [.placeholder("OTP Title")])
        
        // can't test SwiftUI.Image
        XCTAssertNotNil(sut.icon)
        XCTAssertEqual(sut.description, "OTP Title")
        
        // textField extra
        XCTAssertEqual(sut.textField.keyboardType, .number)
        XCTAssert(try XCTUnwrap(sut.textField.toolbar.doneButton.isEnabled))
        XCTAssertNotNil(sut.textField.toolbar.closeButton)
    }
    
    func test_init_shouldSetInitialValues_onEmpty() throws {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let editingStateSpy = ValueSpy(sut.$editingState)
        let resendStateSpy = ValueSpy(sut.$resendState)
        let textFieldSpy = ValueSpy(sut.textField.$state)
        
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [.placeholder("OTP Title")])
        
        // can't test SwiftUI.Image
        XCTAssertNotNil(sut.icon)
        XCTAssertEqual(sut.description, "OTP Title")
        
        // textField extra
        XCTAssertEqual(sut.textField.keyboardType, .number)
        XCTAssert(try XCTUnwrap(sut.textField.toolbar.doneButton.isEnabled))
        XCTAssertNotNil(sut.textField.toolbar.closeButton)
    }
    
    func test_init_shouldSetInitialValues() throws {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "123456",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let editingStateSpy = ValueSpy(sut.$editingState)
        let resendStateSpy = ValueSpy(sut.$resendState)
        let textFieldSpy = ValueSpy(sut.textField.$state)
        
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, ["123456"])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [.noFocus("123456")])
        
        // can't test SwiftUI.Image
        XCTAssertNotNil(sut.icon)
        XCTAssertEqual(sut.description, "OTP Title")
        
        // textField extra
        XCTAssertEqual(sut.textField.keyboardType, .number)
        XCTAssert(try XCTUnwrap(sut.textField.toolbar.doneButton.isEnabled))
        XCTAssertNotNil(sut.textField.toolbar.closeButton)
    }
    
    func test_shouldSetResendStateToButton_onResendDelayIsOverAction() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "123456",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendDelayIsOver())
        scheduler.advance()
        
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, .button])
    }
    
    func test_shouldSetResendStateToTimer_onResendButtonDidTappedAction() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "123456",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendButtonDidTapped())
        scheduler.advance()
        
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, .timer])
    }
    
    func test_shouldSetEditingStateToError_onIncorrectCodeEnteredAction() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "123456",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$editingState)
        
        sut.action.send(CodeAction.IncorrectCodeEntered())
        scheduler.advance()
        
        XCTAssertEqual(spy.values, [.idle, .error("Bad code")])
    }
    
    func test_shouldSetResendStateToNil_onResendCodeDisabledAction() {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(
            initialValue: "123456",
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendCodeDisabled())
        scheduler.advance()
        
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, nil])
    }
    
    func test_shouldChangeValues_onTextEditing() throws {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(initialValue: "", scheduler: scheduler.eraseToAnyScheduler())
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let editingStateSpy = ValueSpy(sut.$editingState)
        let resendStateSpy = ValueSpy(sut.$resendState)
        let textFieldSpy = ValueSpy(sut.textField.$state)
        
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
        
        sut.textField.textViewDidBeginEditing()
        scheduler.advance(by: .milliseconds(500))
        
        XCTAssertEqual(currentValueSpy.values, ["", ""])
        XCTAssertEqual(titleSpy.values, [nil, "OTP Title"])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
            .focus(text: "", cursorPosition: 0),
        ])
        
        sut.textField.setText(to: "1234")
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, ["", "", "1234"])
        XCTAssertEqual(titleSpy.values, [nil, "OTP Title", "OTP Title"])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
            .focus(text: "", cursorPosition: 0),
            .focus(text: "1234", cursorPosition: 4),
        ])
        
        sut.textField.setText(to: "123456")
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, ["", "", "1234", "123456"])
        XCTAssertEqual(titleSpy.values, [nil, "OTP Title", "OTP Title", "OTP Title"])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
            .focus(text: "", cursorPosition: 0),
            .focus(text: "1234", cursorPosition: 4),
            .focus(text: "123456", cursorPosition: 6)
        ])
        
        sut.textField.textViewDidEndEditing()
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, ["", "", "1234", "123456", "123456"])
        XCTAssertEqual(titleSpy.values, [nil, "OTP Title", "OTP Title", "OTP Title", "OTP Title"])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
            .focus(text: "", cursorPosition: 0),
            .focus(text: "1234", cursorPosition: 4),
            .focus(text: "123456", cursorPosition: 6),
            .noFocus("123456")
        ])
    }
    
    func test_shouldChangeEditingAndResendStates_onCodeAction() throws {
        
        let scheduler = DispatchQueue.test
        let sut = makeSUT(initialValue: "", scheduler: scheduler.eraseToAnyScheduler())
        let currentValueSpy = ValueSpy(sut.$value.map(\.current))
        let titleSpy = ValueSpy(sut.$title)
        let editingStateSpy = ValueSpy(sut.$editingState)
        let resendStateSpy = ValueSpy(sut.$resendState)
        let textFieldSpy = ValueSpy(sut.textField.$state)
        
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [.timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
        
        sut.action.send(CodeAction.ResendDelayIsOver())
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [
            .timer, .button])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
        
        sut.action.send(CodeAction.ResendButtonDidTapped())
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [
            .timer, .button, .timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
        
        sut.action.send(CodeAction.IncorrectCodeEntered())
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle, .error("Bad code")])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [
            .timer, .button, .timer])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
        
        sut.action.send(CodeAction.ResendCodeDisabled())
        scheduler.advance()
        
        XCTAssertEqual(currentValueSpy.values, [""])
        XCTAssertEqual(titleSpy.values, [nil])
        XCTAssertEqual(editingStateSpy.values, [.idle, .error("Bad code")])
        XCTAssertEqual(resendStateSpy.values.map(\.?.state), [
            .timer, .button, .timer, nil])
        XCTAssertEqual(textFieldSpy.values, [
            .placeholder("OTP Title"),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialValue: String?,
        timerDelay: TimeInterval = 0,
        errorMessage: String = "Bad code",
        length: Int = 6,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsCodeView.ViewModel {
        
        let parameterCode = Payments.ParameterCode(
            value: initialValue,
            icon: makeImageData(),
            title: "OTP Title",
            timerDelay: timerDelay,
            errorMessage: errorMessage,
            validator: .init(length: length)
        )
        
        return .init(with: parameterCode, scheduler: scheduler)
    }
    
    private func makeImageData() -> ImageData {
        
        .init(with: .make(withColor: .red))!
    }
}

private extension PaymentsCodeView.ViewModel.ResendState {
    
    var state: State {
        switch self {
        case .timer:  return .timer
        case .button: return .button
        }
    }
    
    enum State: Equatable {
        
        case timer, button
    }
}
