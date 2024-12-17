//
//  SearchBarComponentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 28.04.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class SearchBarComponentTests: XCTestCase {
    
    // MARK: fastPayments
    
    func test_init_shouldSetDefaultValues_onDefault() {
        
        let sut = makeSUT(.contacts)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_shouldClearText_onClearTextFieldAction() {
        
        let sut = makeSUT(.contacts)

        sut.setTextFieldTextAndWait("123")

        XCTAssertEqual(sut.textFieldModel.text, "123")

        sut.action.send(.clearTextField)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.textFieldModel.text, nil)
    }
    
    func test_shouldChangeStateToIdle_onIdleAction() {
        
        let sut = makeSUT(.contacts)
        
        sut.setTextFieldStateAndWait(.editing)

        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .editing)
        XCTAssertEqual(sut.state.case, .editing)
        
        sut.action.send(.idle)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.state.case, .idle)
    }
    
    func test_shouldChangeStateToIdle_onIdleTextFieldState() {
        
        let sut = makeSUT(.contacts)

        sut.setTextFieldStateAndWait(.editing)

        XCTAssertEqual(sut.state.case, .editing)

        sut.setTextFieldStateAndWait(.idle)

        XCTAssertEqual(sut.state.case, .idle)
    }
    
    func test_shouldChangeStateToSelected_onSelectedTextFieldState() {
        
        let sut = makeSUT(.contacts)

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.state.case, .idle)

        sut.setTextFieldStateAndWait(.selected)

        XCTAssertEqual(sut.state.case, .selected)
    }
    
    func test_shouldChangeStateToEditingFromIdle_onEditingTextFieldState() {
        
        let sut = makeSUT(.contacts)

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.state.case, .idle)

        sut.setTextFieldStateAndWait(.editing)

        XCTAssertEqual(sut.state.case, .editing)
    }
    
    func test_shouldChangeStateToEditingFromSelected_onEditingTextFieldState() {
        
        let sut = makeSUT(.contacts)

        sut.setTextFieldStateAndWait(.selected)

        XCTAssertEqual(sut.state.case, .selected)

        sut.setTextFieldStateAndWait(.editing)

        XCTAssertEqual(sut.state.case, .editing)
    }
    
    func test_phone_shouldReturnNil_onEmpty() {
        
        let sut = makeSUT(.contacts)
        
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_phone_shouldReturnNil_onInvalidPhone() {
        
        let validator = AlwaysFailingValidator()
        let sut = makeSUT(.contacts, validator)
        let invalidPhone = "5110217"
        
        sut.setTextFieldTextAndWait(invalidPhone)
        
        XCTAssertEqual(validator.isValid(invalidPhone), false)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_phone_shouldReturnText_onValidPhone() {
        
        let validator = Validate.always
        let sut = makeSUT(.contacts, validator)
        let validPhone = "5110217"
                
        sut.setTextFieldTextAndWait("5110217")

        XCTAssertEqual(sut.phone, validPhone)
    }
    
    func test_phone_specialPhoneNumberIsValid_onAnyValidation() {

        let validator = AlwaysFailingValidator()
        let sut = makeSUT(.contacts, validator)
        let specialPhoneNumber = "+7 0115110217"
        
        sut.setTextFieldTextAndWait(specialPhoneNumber)
        
        XCTAssertEqual(validator.isValid(specialPhoneNumber), false)
        XCTAssertEqual(sut.phone, specialPhoneNumber)
    }
    
    func test_textPublisher_shouldNotChangeInputValue_onBanks() {
        
        let sut = makeSUT(.banks)
        let spy = ValueSpy(sut.textFieldModel.textPublisher)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [nil])

        sut.setTextFieldTextAndWait("1234567")
        
        XCTAssertEqual(spy.values, [nil, "1234567"])

        sut.setTextFieldTextAndWait("")
        
        XCTAssertEqual(spy.values, [nil, "1234567", ""])

        sut.setTextFieldTextAndWait(nil)
        
        XCTAssertEqual(spy.values, [nil, "1234567", "", nil])
    }
    
    func test_phone_shouldFlipToPhoneOnValid_onBanks() {
        
        let sut = makeSUT(.banks)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.phone, nil)

        sut.setTextFieldTextAndWait("1234567")
        
        XCTAssertEqual(sut.phone, nil)

        sut.setTextFieldTextAndWait("")
        
        XCTAssertEqual(sut.phone, nil)

        sut.setTextFieldTextAndWait("79111111111")
        
        XCTAssertEqual(sut.phone, "79111111111")

        sut.setTextFieldTextAndWait("7911 111 11 11")
        
        XCTAssertEqual(sut.phone, "7911 111 11 11")

        sut.setTextFieldTextAndWait("+7 911 111-11-11")
        
        XCTAssertEqual(sut.phone, "+7 911 111-11-11")
    }
    
    // MARK: - factory helpers
    
    private typealias ViewModel = SearchBarView.ViewModel
    
    func test_init_shouldSetInitialValues_banks() throws {
        
        let sut: ViewModel = .banks()
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_contacts() throws {
        
        let sut: ViewModel = .contacts()
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_countries() throws {
        
        let sut: ViewModel = .countries()
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_generalWithText() throws {
        
        let sut: ViewModel = .generalWithText("Some arbitrary text")
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, .ic24Search)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_nameOrTaxCode() throws {
        
        let sut: ViewModel = .nameOrTaxCode()
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, .ic24Search)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_fastPayments_contacts() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.contacts))
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_fastPayments_banksAndCountries_emptyPnone() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.banksAndCountries(phone: "")))
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_fastPayments_banksAndCountries_nonEmptyPnone() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.banksAndCountries(phone: "ABCD")))
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_abroad() throws {
        
        let sut: ViewModel = .searchBar(for: .abroad)
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, .ic24Search)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_select_contacts() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.contacts))
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_select_banks() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.banks(phone: nil)))
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_select_banksFullInfo() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.banksFullInfo))
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_searchBar_select_countries() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.countries))
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetInitialValues_withText() throws {
        
        let sut: ViewModel = .withText("Text here")
        
        trackForMemoryLeaks(sut)
        
        XCTAssertEqual(sut.textFieldModel.hasValue, false)
        XCTAssertEqual(sut.textFieldModel.isActive, false)
        XCTAssertEqual(sut.textFieldModel.text, nil)
        XCTAssertEqual(sut.textFieldModel.phoneNumberState, .idle)
        XCTAssertEqual(sut.textFieldModel.style, .general)
        
        XCTAssertEqual(sut.state.case, .idle)
        XCTAssertEqual(sut.icon, nil)
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phone, nil)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_banks() throws {
        
        let sut: ViewModel = .banks()
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .banks)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_contacts() throws {
        
        let sut: ViewModel = .contacts()
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .contacts)
        XCTAssertEqual(phoneNumberModel.filterSymbols, ["-", "(", ")", "+"])
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, .russian)
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_countries() throws {
        
        let sut: ViewModel = .countries()
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .countries)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_generalWithText() throws {
        
        let sut: ViewModel = .generalWithText("Some arbitrary text")
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .text("Some arbitrary text"))
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_nameOrTaxCode() throws {
        
        let sut: ViewModel = .nameOrTaxCode()
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .text("Название или ИНН"))
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }
    
    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_fastPayments_contacts() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.contacts))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .contacts)
        XCTAssertEqual(phoneNumberModel.filterSymbols, ["-", "(", ")", "+"])
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, .russian)
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_fastPayments_banksAndCountries_emptyPnone() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.banksAndCountries(phone: "")))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .contacts)
        XCTAssertEqual(phoneNumberModel.filterSymbols, ["-", "(", ")", "+"])
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, .russian)
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_fastPayments_banksAndCountries_nonEmptyPnone() throws {
        
        let sut: ViewModel = .searchBar(for: .fastPayments(.banksAndCountries(phone: "ABCD")))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .contacts)
        XCTAssertEqual(phoneNumberModel.filterSymbols, ["-", "(", ")", "+"])
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, .russian)
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_abroad() throws {
        
        let sut: ViewModel = .searchBar(for: .abroad)
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .abroad)
        XCTAssertEqual(phoneNumberModel.placeHolder, .countries)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_select_contacts() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.contacts))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .contacts)
        XCTAssertEqual(phoneNumberModel.filterSymbols, ["-", "(", ")", "+"])
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, .russian)
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_select_banks() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.banks(phone: nil)))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .banks)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_select_banksFullInfo() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.banksFullInfo))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .banks)
        XCTAssertEqual(phoneNumberModel.placeHolder, .banks)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_searchBar_select_countries() throws {
        
        let sut: ViewModel = .searchBar(for: .select(.countries))
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .countries)
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    func test_init_shouldSetPhoneNumberModelInitialValues_withText() throws {
        
        let sut: ViewModel = .withText("Text here")
        let phoneNumberModel = try XCTUnwrap(sut.textFieldModel as? TextViewPhoneNumberView.ViewModel)
        
        XCTAssertEqual(phoneNumberModel.text, nil)
        XCTAssertEqual(phoneNumberModel.phoneNumberState, .idle)
        XCTAssertEqual(phoneNumberModel.isEditing.value, false)
        XCTAssertNotNil(phoneNumberModel.toolbar?.closeButton)
        XCTAssertNotNil(phoneNumberModel.toolbar?.doneButton)
        XCTAssertEqual(phoneNumberModel.style, .general)
        XCTAssertEqual(phoneNumberModel.placeHolder, .text("Text here"))
        XCTAssertEqual(phoneNumberModel.filterSymbols, nil)
        XCTAssertEqual(phoneNumberModel.countryCodeReplaces, [])
        XCTAssertNotNil(phoneNumberModel.phoneNumberFormatter)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        _ placeholder: TextViewPhoneNumberView.ViewModel.PlaceHolder,
        _ validator: Validator = PhoneValidator(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SearchBarView.ViewModel {
        
        let textFieldModel: TextViewPhoneNumberView.ViewModel = .init(placeholder)
        let sut = SearchBarView.ViewModel(
            textFieldModel: textFieldModel,
            validator: validator
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

// MARK: - DSL

extension SearchBarView.ViewModel {
    
    func setTextFieldStateAndWait(_ state: TextViewPhoneNumberView.ViewModel.State) {
        
        textFieldModel.phoneNumberState = state
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    func setTextFieldTextAndWait(_ text: String?) {
        
        textFieldModel.setText(to: text)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}

struct AlwaysFailingValidator: Validator {
    
    func isValid(_ input: String) -> Bool { return false }
}

extension SearchBarView.ViewModel.State {
    
    var `case`: Case {
        
        switch self {
        case .idle:
            return .idle
        case .selected:
            return .selected
        case .editing:
            return .editing
        }
    }
    
    enum Case: Equatable {
        case idle, selected, editing
    }
}

private extension PhoneNumberTextFieldViewModel {
    
    var hasValue: Bool { text != "" && text != nil }
    var isActive: Bool {
        
        if phoneNumberState == .selected {
            return true
        }
        
        if let text = text, text.isEmpty == false {
            return true
        }
        
        return false
    }
    
    var style: TextViewPhoneNumberView.ViewModel.Style { .general }
}
