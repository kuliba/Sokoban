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
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        let textField = try textField(sut)
        let spy = ValueSpy(textField.$state)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
        ])

        textField.startEditing()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
            .editing(.empty),
        ])

        textField.insertAtCursor("abcd")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values, [
            .placeholder(title),
            .editing(.empty),
            .editing(.init("abcd", cursorAt: 4)),
        ])

        textField.insert("-", atCursor: 2)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
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
        let parameterInput = makeParameterInput(
            title: title
        )
        let operation = makePaymentsOperation(with: parameterInput)
        let model: Model = .mockWithEmptyExcept()
        let sut = SUT(
            operation: operation,
            model: model,
            closeAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeParameterInput(
        id: String = UUID().uuidString,
        title: String = UUID().uuidString
    ) -> Payments.ParameterInput {
        
        .init(
            .init(id: id, value: nil),
            title: title,
            validator: .anyValue
        )
    }
    
    private func makePaymentsOperation(
        service: Payments.Service = .abroad,
        with parameter: PaymentsParameterRepresentable
    ) -> Payments.Operation {
        
        makePaymentsOperation(service: service, parameters: [parameter])
    }
    
    private func makePaymentsOperation(
        service: Payments.Service = .abroad,
        parameters: [PaymentsParameterRepresentable]
    ) -> Payments.Operation {
        
        .init(
            service: service,
            source: nil,
            steps: [
                .init(
                    parameters: parameters,
                    front: .init(
                        visible: parameters.map(\.id),
                        isCompleted: true
                    ),
                    back: .empty()
                )
            ],
            visible: parameters.map(\.id)
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
