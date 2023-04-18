//
//  PaymentsCodeViewComponentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 12.04.2023.
//

@testable import ForaBank
@testable import TextFieldRegularComponent
import XCTest

final class PaymentsCodeViewComponentTests: XCTestCase {
    
    typealias CodeAction = PaymentsParameterViewModelAction.Code
    
    func test_init_shouldSetInitialValues() throws {
        
        let sut = makeSUT()
        
        // can't test SwiftUI.Image
        XCTAssertNotNil(sut.icon)
        
        XCTAssertEqual(sut.description, "OTP Title")
        XCTAssertEqual(sut.title, nil)
        XCTAssertEqual(sut.editingState, .idle)
        XCTAssertEqual(try XCTUnwrap(sut.resendState?.state), .timer)
        
        // textField
        XCTAssertNotNil(sut.textField)
        XCTAssertEqual(sut.textField.text, "123456")
        XCTAssertEqual(sut.textField.isEditing, false)
        XCTAssertEqual(sut.textField.keyboardType, .number)
        XCTAssert(try XCTUnwrap(sut.textField.toolbar.doneButton.isEnabled))
        XCTAssertNotNil(sut.textField.toolbar.closeButton)
    }
    
    func test_shouldSetResendStateToButton_onResendDelayIsOverAction() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendDelayIsOver())
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, .button])
    }
    
    func test_shouldSetResendStateToTimer_onResendButtonDidTappedAction() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendButtonDidTapped())
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, .timer])
    }
    
    func test_shouldSetEditingStateToError_onIncorrectCodeEnteredAction() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.$editingState)
        
        sut.action.send(CodeAction.IncorrectCodeEntered())
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(spy.values, [.idle, .error("")])
    }
    
    func test_shouldSetResendStateToNil_onResendCodeDisabledAction() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.$resendState)
        
        sut.action.send(CodeAction.ResendCodeDisabled())
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        XCTAssertEqual(spy.values.map(\.?.state), [.timer, nil])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        value: String = "123456",
        timerDelay: TimeInterval = 0,
        errorMessage: String = "",
        length: Int = 6
    ) -> PaymentsCodeView.ViewModel {
        
        let parameterCode = Payments.ParameterCode(
            value: value,
            icon: makeImageData(),
            title: "OTP Title",
            timerDelay: timerDelay,
            errorMessage: errorMessage,
            validator: .init(length: length)
        )
        
        return .init(with: parameterCode)
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
