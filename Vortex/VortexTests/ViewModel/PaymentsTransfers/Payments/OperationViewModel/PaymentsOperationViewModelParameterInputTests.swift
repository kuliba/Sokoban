//
//  PaymentsOperationViewModelParameterInputTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.11.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsOperationViewModelParameterInputTests: XCTestCase {
    
    func test_init_shouldSetInputTitleAsPlaceholder() throws {
        
        let title = UUID().uuidString
        let sut = makeSUT(title: title)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let textField = try textField(sut)
        let spy = ValueSpy(textField.$state)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
        ])
    }
    
    func test_textFieldEditing_shouldSetCursor() throws {
        
        let title = UUID().uuidString
        let sut = makeSUT(title: title)
        
        let textField = try textField(sut)
        let spy = ValueSpy(textField.$state)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
        ])
        
        textField.startEditingAndWait()
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
            .editing(.empty),
        ])
        
        textField.insertAtCursorAndWait("abcd")
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
            .editing(.empty),
            .editing(.init("abcd", cursorAt: 4)),
        ])
        
        textField.insertAndWait("-", atCursor: 2)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
            .editing(.empty),
            .editing(.init("abcd", cursorAt: 4)),
            .editing(.init("ab-cd", cursorAt: 3)),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsOperationViewModel
    
    private func makeSUT(
        title: String = UUID().uuidString,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let operation = makePaymentsOperation(
            inputTitle: title
        )
        let model: Model = .mockWithEmptyExcept()
        let sut = SUT(
            operation: operation,
            model: model,
            closeAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        return sut
    }
    
    private func makePaymentsOperation(
        inputTitle: String = UUID().uuidString
    ) -> Payments.Operation {
        
        let parameterInput = Payments.ParameterInput(
            .init(
                id: Payments.Parameter.Identifier.sfpMessage.rawValue,
                value: nil
            ),
            title: inputTitle,
            validator: .anyValue
        )
        
        let parameterBank = Payments.ParameterSelectBank(
            .init(
                id: Payments.Parameter.Identifier.sfpBank.rawValue,
                value: "1crt88888881"
            ),
            icon: .empty,
            title: "Bank Title",
            options: [
                .init(
                    id: "1crt88888881",
                    name: "Bank",
                    subtitle: nil,
                    icon: nil,
                    isFavorite: false,
                    searchValue: "Bank"
                )
            ],
            placeholder: "Bank Placeholder",
            keyboardType: .normal
        )
        
        return makePaymentsOperation(
            service: .sfp,
            parameters: [parameterInput, parameterBank])
    }
    
    private func makePaymentsOperation(
        service: Payments.Service = .sfp,
        parameters: [PaymentsParameterRepresentable]
    ) -> Payments.Operation {
        
        let parameterIDs = parameters.map(\.id)
        
        return .init(
            service: service,
            source: .mock(.init(
                service: service,
                parameters: parameters.map(\.parameter)
            )),
            steps: [
                .init(
                    parameters: parameters,
                    front: .init(
                        visible: parameterIDs,
                        isCompleted: false
                    ),
                    back: .init(
                        stage: .remote(.start),
                        required: parameterIDs,
                        processed: nil
                    )
                )
            ],
            visible: parameterIDs
        )
    }
    
    private func textField(
        _ sut: SUT
    ) throws -> RegularFieldViewModel {
        
        try XCTUnwrap(sut.inputTextField, "Expected to have TextField of `PaymentsInputView.ViewModel` in `PaymentsOperationViewModel`, but got nil.")
    }
}

private extension PaymentsOperationViewModel {
    
    var inputViewModel: PaymentsInputView.ViewModel? {
        
        feed
            .flatMap(\.items)
            .compactMap { $0 as? PaymentsInputView.ViewModel }
            .first
    }
    
    var inputTextField: RegularFieldViewModel? {
        
        inputViewModel?.textField
    }
}

private extension RegularFieldViewModel {
    
    func startEditingAndWait(
        timeout: TimeInterval = 0.3
    ) {
        startEditing()
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func insertAtCursorAndWait(
        _ text: String,
        timeout: TimeInterval = 0.3
    ) {
        insertAtCursor(text)
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func insertAndWait(
        _ text: String,
        atCursor cursor: Int,
        timeout: TimeInterval = 0.3
    ) {
        insert(text, atCursor: cursor)
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
