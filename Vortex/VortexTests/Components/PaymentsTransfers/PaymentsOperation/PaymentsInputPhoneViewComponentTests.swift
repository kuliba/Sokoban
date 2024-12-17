//
//  PaymentsInputPhoneViewComponentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import ForaBank
@testable import TextFieldComponent
import SwiftUI
import XCTest

final class PaymentsInputPhoneViewComponentTests: XCTestCase {
    
    // MARK: - No Spy
    
    func test_init_shouldSetValues_noSpy() {
        
        let sut = makeSUT(countryCodes: nil).sut
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: nil, current: nil))
        XCTAssertNoDiff(sut.title, nil)
        XCTAssertNoDiff(sut.textView.state, .placeholder("Enter phone number"))
    }
    
    func test_beginEditing_shouldChangeValues_noSpy() {
        
        let sut = makeSUT(countryCodes: nil).sut
        
        startEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: nil, current: ""))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .editing(.empty))
    }
    
    func test_textChange_shouldNotSubstituteOnEmptyCountryCodes_noSpy() {
        
        let countryCodes: [CountryCodeReplace] = []
        let sut = makeSUT(countryCodes: countryCodes).sut

        startEditingAndWait(sut.textView)

        let input: String = "3"
        insertAtCursorAndWait(.init(input), sut.textView)

        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: "", current: "+3"))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .editing(.init("+3", cursorAt: 2)))
        XCTAssertFalse(countryCodes.map(\.from).contains(input))
    }
    
    func test_textChange_shouldNotSubstituteOnCountryCodesMismatch_noSpy() {
        
        let countryCodes: [CountryCodeReplace] = .russian
        let sut = makeSUT(countryCodes: countryCodes).sut
        
        startEditingAndWait(sut.textView)
        
        let input: String = "4"
        insertAtCursorAndWait(.init(input), sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: "", current: "+4"))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .editing(.init("+4", cursorAt: 2)))
        XCTAssertFalse(countryCodes.map(\.from).contains(input))
    }
    
    func test_textChange_shouldSubstituteOnCountryCodesMatch_noSpy() {
        
        let countryCodes: [CountryCodeReplace] = .russian
        let sut = makeSUT(countryCodes: countryCodes).sut

        startEditingAndWait(sut.textView)
        
        let input: String = "3"
        insertAtCursorAndWait(.init(input), sut.textView)

        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: "", current: "+3"))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .editing(.init("+3", cursorAt: 2)))
        XCTAssertFalse(countryCodes.map(\.from).contains(input))
    }
    
    func test_endEditing_shouldChangeValues_noSpy_noCountryCodesMatch() {
        
        let sut = makeSUT(countryCodes: nil).sut
        
        startEditingAndWait(sut.textView)
        insertAtCursorAndWait("3", sut.textView)
        finishEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: "+3", current: "+3"))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .noFocus("+3"))
    }
    
    func test_endEditing_shouldNotChangeValues_noSpy_countryCodeMatch() {
        
        let countryCodes: [CountryCodeReplace] = .russian
        let sut = makeSUT(countryCodes: countryCodes).sut

        startEditingAndWait(sut.textView)
        
        let input: String = "3"
        insertAtCursorAndWait(.init(input), sut.textView)
        finishEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(sut.value, .init(id: "phoneInput", last: "+3", current: "+3"))
        XCTAssertNoDiff(sut.title, "Enter phone number")
        XCTAssertNoDiff(sut.textView.state, .noFocus("+3"))
        XCTAssertFalse(countryCodes.map(\.from).contains(input))
    }
    
    // MARK: Using Spy
    
    func test_init_shouldSetValues() {
        
        let (sut, valueSpy, titleSpy) = makeSUT(countryCodes: nil)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(valueSpy.values, [
            .init(id: "phoneInput", last: nil, current: nil)
        ])
        XCTAssertNoDiff(titleSpy.values, ["Enter phone number"])
        XCTAssertNoDiff(sut.textView.state, .placeholder("Enter phone number"))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(valueSpy.values, [
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: nil),
        ])
        XCTAssertNoDiff(titleSpy.values, [
            "Enter phone number",
            nil,
        ])
        XCTAssertNoDiff(sut.textView.state, .placeholder("Enter phone number"))
    }
    
    func test_beginEditing_shouldChangeValues() {
        
        let (sut, valueSpy, titleSpy) = makeSUT(countryCodes: nil)
                
        startEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(valueSpy.values, [
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: ""),
        ])
        XCTAssertNoDiff(titleSpy.values, [
            "Enter phone number",
            nil,
            "Enter phone number",
        ])
        XCTAssertNoDiff(sut.textView.state, .editing(.init("", cursorAt: 0)))
    }
    
    func test_textChange_shouldChangeValues() {
        
        let (sut, valueSpy, titleSpy) = makeSUT(countryCodes: .russian)
                
        startEditingAndWait(sut.textView)
        insertAtCursorAndWait("3", sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(valueSpy.values, [
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: ""),
            .init(id: "phoneInput", last: "",  current: "+3"),
        ])
        XCTAssertNoDiff(titleSpy.values, [
            "Enter phone number",
            nil,
            "Enter phone number",
            "Enter phone number",
        ])
        XCTAssertNoDiff(sut.textView.state, .editing(.init("+3", cursorAt: 2)))
    }
    
    func test_endEditing_shouldChangeValues() {
        
        let (sut, valueSpy, titleSpy) = makeSUT(countryCodes: .russian)
                
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        startEditingAndWait(sut.textView)
        insertAtCursorAndWait("3", sut.textView)
        finishEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.icon, .ic24Smartphone)
        XCTAssertNoDiff(valueSpy.values, [
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: nil),
            .init(id: "phoneInput", last: nil, current: ""),
            .init(id: "phoneInput", last: "",  current: "+3"),
            .init(id: "phoneInput", last: "+3",  current: "+3"),
        ])
        XCTAssertNoDiff(titleSpy.values, [
            "Enter phone number",
            nil,
            "Enter phone number",
            "Enter phone number",
            "Enter phone number",
        ])
        XCTAssertNoDiff(sut.textView.state, .noFocus("+3"))
    }
    
    func test_actionButtonSpy_shouldNotChangeOnTextEditing() {
        
        let sut = makeSUT(countryCodes: nil).sut
        let actionButtonSpy = ValueSpy(sut.$actionButton.map(\.?.icon))

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(actionButtonSpy.values, [.ic24User])
        
        startEditingAndWait(sut.textView)
        insertAtCursorAndWait("3", sut.textView)
        finishEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(actionButtonSpy.values, [.ic24User])
    }
    
    func test_isValid_shouldFlipToTrue_onValidPhoneNumber() {
        
        let sut = makeSUT(countryCodes: nil).sut

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(sut.isValid, false)
        
        startEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.isValid, false)

        insertAtCursorAndWait("3", sut.textView)
        
        XCTAssertNoDiff(sut.isValid, false)

        finishEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.isValid, false)
        
        startEditingAndWait(sut.textView)
        
        XCTAssertNoDiff(sut.isValid, false)

        replaceWithAndWait(text: "7911 111 11 11", sut.textView)

        XCTAssertNoDiff(sut.isValid, true)

        finishEditingAndWait(sut.textView)

        XCTAssertNoDiff(sut.isValid, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialValue: String? = nil,
        countryCodes: [CountryCodeReplace]?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsInputPhoneView.ViewModel,
        valueSpy: ValueSpy<PaymentsParameterViewModel.Value>,
        titleSpy: ValueSpy<String?>
    ) {
        let parameter: Payments.ParameterInputPhone = .init(
            .init(id: "phoneInput", value: initialValue),
            title: "Enter phone number",
            countryCode: countryCodes
        )
        let sut = PaymentsInputPhoneView.ViewModel(
            with: parameter,
            model: .emptyMock
        )
        let valueSpy = ValueSpy(sut.$value)
        let titleSpy = ValueSpy(sut.$title)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(valueSpy, file: file, line: line)
        trackForMemoryLeaks(titleSpy, file: file, line: line)
        
        return (sut, valueSpy, titleSpy)
    }
    
    private func startEditingAndWait(
        _ sut: RegularFieldViewModel
    ) {
        sut.startEditing()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }

    private func finishEditingAndWait(
        _ sut: RegularFieldViewModel
    ) {
        sut.finishEditing()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }

    private func insertAtCursorAndWait(
        _ text: String,
        _ sut: RegularFieldViewModel
    ) {
        sut.insertAtCursor(text)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    private func replaceWithAndWait(
        text: String,
        _ sut: RegularFieldViewModel
    ) {
        sut.setText(to: text)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)    }
    
    private func deleteLastAndWait(
        _ sut: RegularFieldViewModel
    ) {
        sut.deleteLast()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}
