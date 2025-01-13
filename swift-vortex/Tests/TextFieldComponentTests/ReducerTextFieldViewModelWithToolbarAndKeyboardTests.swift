//
//  ReducerTextFieldViewModelWithToolbarAndKeyboardTests.swift
//  
//
//  Created by Igor Malyarov on 02.06.2023.
//

import TextFieldDomain
import TextFieldModel
@testable import TextFieldUI
import XCTest

final class ReducerTextFieldViewModelWithToolbarAndKeyboardTests: XCTestCase {
    
    func test_init_shouldSetToolbar() {
        
        let sut = makeSUT(.noFocus(""))
        
        XCTAssertNoDiff(sut.toolbar?.closeButton?.label, .title("Close"))
        XCTAssertNoDiff(sut.toolbar?.doneButton.label, .title("Done"))
    }
    
    func test_init_shouldSetToolbarWithDone() {
        
        let sut = makeSUT(.noFocus(""), toolbar: .doneButton())
        
        XCTAssertNil(sut.toolbar?.closeButton)
        XCTAssertNoDiff(sut.toolbar?.doneButton.label, .title("Done"))
    }
    
    func test_init_shouldSetToolbarWithTwoButtons() {
        
        let sut = makeSUT(.noFocus(""), toolbar: .test())
        
        XCTAssertNoDiff(sut.toolbar?.closeButton?.label, .title("Close"))
        XCTAssertNoDiff(sut.toolbar?.doneButton.label, .title("Done"))
    }
    
    // MARK: - Helpers
    
    private typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>
    
    private func makeSUT(
        _ state: TextFieldState,
        placeholderText: String = "Placeholder",
        keyboardType: KeyboardType = .default,
        toolbar: ToolbarViewModel = .test(),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ViewModel {
        
        let sut = ViewModel(
            initialState: state,
            reducer: TransformingReducer(placeholderText: placeholderText),
            keyboardType: keyboardType,
            toolbar: toolbar,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension ToolbarViewModel {
    
    static func doneButton(
        label: ButtonViewModel.Label = .title("Done")
    ) -> ToolbarViewModel {
        
        .init(doneButton: .init(label: label, action: {}))
    }
    
    static func test(
        doneButtonLabel: ButtonViewModel.Label = .title("Done"),
        closeButtonLabel: ButtonViewModel.Label = .title("Close")
    ) -> ToolbarViewModel {
        
        .init(
            doneButton: .init(label: doneButtonLabel, action: {}),
            closeButton: .init(label: closeButtonLabel, action: {})
        )
    }
}

private extension TextFieldView.TextFieldConfig {
    
    static let test: Self = .init(font: .systemFont(ofSize: 19), textColor: .blue, tintColor: .orange, backgroundColor: .clear, placeholderColor: .gray)
}
