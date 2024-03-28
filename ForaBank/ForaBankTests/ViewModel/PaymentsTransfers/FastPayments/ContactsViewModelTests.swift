//
//  ContactsViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.05.2023.
//

import Combine
@testable import ForaBank
@testable import TextFieldComponent
import struct SwiftUI.Image
import XCTest

final class ContactsViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetInitialValues_abroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(sut.title, "В какую страну?")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["latestPayments", "countries"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .countries])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select, .select])
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(sut.title, "В какую страну?")
    }
    
    func test_init_shouldSetInitialValues_fastPayments_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["latestPayments", "contacts"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select, .fastPayment])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_empty() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "")))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "")))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["latestPayments", "contacts"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select, .fastPayment])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_nonEmpty() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "123")))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["latestPayments", "contacts"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select, .fastPayment])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["latestPayments", "contacts"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select, .fastPayment])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
    }
    
    func test_init_shouldSetInitialModeToContacts_fastPayments_banksAndCountries_empty() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "")))
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
    }
    
    func test_init_shouldSetInitialModeToContacts_fastPayments_banksAndCountries_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "123")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
    }
    
    func test_init_shouldSetInitialModeToContacts_fastPayments_banksAndCountries_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
    }
    
    func test_init_shouldSetInitialValues_select_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["contacts"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.contacts])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select])
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.title, "Выберите контакт")
    }
    
    func test_init_shouldSetInitialValues_select_banks() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.title, "Выберите банк")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["banks"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.banks])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select])
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.title, "Выберите банк")
    }
    
    func test_init_shouldSetInitialValues_select_banksFullInfo() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.title, "Выберите банк")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["banks"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.banks])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select])
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.title, "Выберите банк")
    }
    
    func test_init_shouldSetInitialValues_select_countries() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), [])
        XCTAssertNoDiff(sut.visible.map(\.type), [])
        XCTAssertNoDiff(sut.visible.map(\.mode), [])
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.title, "Выберите страну")
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.textFieldModelText, nil)
        XCTAssertNoDiff(sut.textFieldModelStateCase, .idle)
        XCTAssertNoDiff(sut.searchText, nil)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        
        XCTAssertNoDiff(sut.visible.map(\.id), ["countries"])
        XCTAssertNoDiff(sut.visible.map(\.type), [.countries])
        XCTAssertNoDiff(sut.visible.map(\.mode), [.select])
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.title, "Выберите страну")
    }
    
    // MARK: - init KeyboardType
    
    func test_init_shouldSetKeyboardType_abroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_fastPayments_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_fastPayments_banksAndCountries_empty() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_fastPayments_banksAndCountries_nonEmpty() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_fastPayments_banksAndCountries_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_select_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_select_banks() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_select_banksFullInfo() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    func test_init_shouldSetKeyboardType_select_countries() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.keyboardType, .default)
    }
    
    // MARK: - Last Payments Section
    
    func test_lastPaymentsSectionShouldBeVisibleOnInit_fastPayments_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))

        scheduler.advance(by: 300)
        
        XCTAssertTrue(sut.isLastPaymentsSectionVisible)
    }
    
    func test_lastPaymentsSectionShouldBeVisibleOnInit_abroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.$mode)
        
        scheduler.advance(by: 300)
        
        XCTAssertTrue(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.abroad,])
    }
    
    func test_lastPaymentsSectionShouldNotBeVisibleOnInit_select_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.$mode)
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.contacts),])
    }
    
    func test_lastPaymentsSectionShouldNotBeVisibleOnInit_select_banks() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.$mode)
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.banks(phone: nil)),])
    }
    
    func test_lastPaymentsSectionShouldNotBeVisibleOnInit_select_banksFullInfo() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.$mode)
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.banksFullInfo),])
    }
    
    func test_lastPaymentsSectionShouldNotBeVisibleOnInit_select_countries() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.$mode)
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.countries),])
    }
    
    func test_lastPaymentsSectionShouldChangeViisibilityOnTextFieldActivationDeactivation_fastPayments_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertTrue(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertTrue(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.fastPayments(.contacts)])
    }
    
    func test_lastPaymentsSectionShouldNotChangeViisibilityOnTextFieldActivationDeactivation_abroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertTrue(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertTrue(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertTrue(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.abroad])
    }
    
    func test_lastPaymentsSectionShouldNotChangeViisibilityOnTextFieldActivationDeactivation_select_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.contacts)])
    }
    
    func test_lastPaymentsSectionShouldNotChangeViisibilityOnTextFieldActivationDeactivation_select_banks() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.banks(phone: nil))])
    }
    
    func test_lastPaymentsSectionShouldNotChangeViisibilityOnTextFieldActivationDeactivation_select_banksFullInfo() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.banksFullInfo)])
    }
    
    func test_lastPaymentsSectionShouldNotChangeViisibilityOnTextFieldActivationDeactivation_select_countries() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.$mode)

        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.activateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)

        sut.deactivateTextFieldAndWait(on: scheduler)

        XCTAssertFalse(sut.isLastPaymentsSectionVisible)
        XCTAssertNoDiff(spy.values, [.select(.countries)])
    }
    
    // MARK: - visible should change on mode change
    
    func test_visible_shouldChange_onModeChange() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let idSpy = ValueSpy(sut.$visible.map { $0.map(\.id) })
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let modeSpy = ValueSpy(sut.$visible.map { $0.map(\.mode) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(idSpy.values, [
            [],
            ["latestPayments", "countries"],
        ])
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .countries],
        ])
        XCTAssertNoDiff(modeSpy.values, [
            [],
            [.select, .select],
        ])
        
        sut.setModeAndWait(.fastPayments(.contacts), on: scheduler)
        
        XCTAssertNoDiff(idSpy.values, [
            [],
            ["latestPayments", "countries"],
            ["latestPayments"],
        ])
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments],
        ])
        XCTAssertNoDiff(modeSpy.values, [
            [],
            [.select, .select],
            [.select],
        ])
        
        sut.setModeAndWait(.fastPayments(.banksAndCountries(phone: "123")), on: scheduler)
        
        XCTAssertNoDiff(idSpy.values, [
            [],
            ["latestPayments", "countries"],
            ["latestPayments"],
            ["countries"],
        ])
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments],
            [.countries],
        ])
        XCTAssertNoDiff(modeSpy.values, [
            [],
            [.select, .select],
            [.select],
            [.select],
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromAbroadToContacts() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .countries],
        ])
        
        sut.setModeAndWait(.fastPayments(.contacts), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments],
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromContactsToBanksAndCountries() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        sut.setModeAndWait(.fastPayments(.banksAndCountries(phone: "123")), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.banksPreferred, .banks, .countries]
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromBanksAndCountriesToSelectContacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
        ])
        
        sut.setModeAndWait(.select(.contacts), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.contacts]
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromBSelectContactsToAbroad() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
        ])
        
        sut.setModeAndWait(.abroad, on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.latestPayments, .countries]
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromSelectContactsToBanks() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.contacts],
        ])
        
        sut.setModeAndWait(.select(.banks(phone: nil)), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.contacts],
            []
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromBanksToBanksFullInfo() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banks],
        ])
        
        sut.setModeAndWait(.select(.banksFullInfo), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banks],
            [.banks]
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromBanksFullInfoToCountries() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banks],
        ])
        
        sut.setModeAndWait(.select(.countries), on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.banks],
            []
        ])
    }
    
    func test_visibleType_shouldChange_onModeChange_fromCountriesToAbroad() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let typeSpy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.contacts],
        ])
        
        sut.setModeAndWait(.abroad, on: scheduler)
        
        XCTAssertNoDiff(typeSpy.values, [
            [],
            [.contacts],
            []
        ])
    }
    
    // MARK: - searchFieldModel text change
    
    func test_textFieldChange_shouldNotChangeFilteredOnDigitInput_onAbroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)

        sut.typeAndWait("1", on: scheduler)
        
        XCTAssertNoDiff(sut.countriesSection?.filter.value, "")
    }
    
    func test_textFieldChange_shouldChangeFiltered_onAbroad() {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.countriesSection?.filter.value, "Abc")
    }
    
    func test_textFieldChange_shouldChange_helpers_onFastPayments_letter_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, nil)
        XCTAssertNoDiff(sut.banksSection?.phone.value, nil)

        sut.typeAndWait("q", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "q")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "q")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "q")
    }
    
    func test_textFieldChange_shouldChange_helpers_onFastPayments_text_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, nil)
        XCTAssertNoDiff(sut.banksSection?.phone.value, nil)

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldChange_helpers_onFastPayments_digit_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, nil)
        XCTAssertNoDiff(sut.banksSection?.phone.value, nil)

        sut.typeAndWait("1", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "+1")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "+1")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "+1")

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldChange_helpers_onFastPayments_replacement_contacts() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, nil)
        XCTAssertNoDiff(sut.banksSection?.phone.value, nil)

        sut.typeAndWait("9", on: scheduler)
        // TODO: добавить тесты!!!

       /* XCTAssertNoDiff(sut.contactsSection?.filter.value, "+7 9")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "+7 9")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "+7 9")*/

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldChange_helpers_onFastPayments_banksAndCountries_emptyText() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "")))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, nil)
        XCTAssertNoDiff(sut.banksSection?.phone.value, nil)

        sut.typeAndWait("1", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "+1")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "+1")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "+1")

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldChangeModeToBanksAndCountries_onFastPayments_contacts_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertTrue(sut.phoneIsValid)
        XCTAssertNoDiff(sut.validatedPhone, "+7 911 111-11-11")
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldSendBankClientRequestModelActon_onFastPayments_contacts__onValidPhone() {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.BankClient.Request })
        
        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [.init(phone: "79111111111")])
        XCTAssertTrue(sut.phoneIsValid)
    }
    
    func test_textFieldChange_shouldNotSendBankClientRequestModelActon_onFastPayments_contacts__onInvalidPhone() {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.BankClient.Request })

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_textFieldChange_shouldSendLatestPaymentsBanksListRequestModelActon_onFastPayments_contacts__onValidPhone() {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.LatestPayments.BanksList.Request })
        
        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [.init(phone: "+7 911 111-11-11")])

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldNotSendLatestPaymentsBanksListRequestModelActon_onFastPayments_contacts__onInvalidPhone() {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.LatestPayments.BanksList.Request })

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_textFieldChange_shouldChangeVisible_onFastPayments_contacts_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])

        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.visible.map(\.type), [.contacts])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_textFieldChange_shouldNotChange_onFastPayments_contacts_nilText() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
        
        sut.typeAndWait(nil, on: scheduler)
        
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.textFieldStateCase, .idle)
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.visible.map(\.type), [.latestPayments, .contacts])
    }
    
    func test_textFieldChange_shouldChangeMode_onFastPayments_banksAndCountries_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        sut.typeAndWait("+7 911 333 33 33", on: scheduler)
        
        XCTAssertNoDiff(sut.validatedPhone, "+7 911 333-33-33")
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 333-33-33")))
        
        sut.typeAndWait("+7 911 777 77 77", on: scheduler)
        
        XCTAssertNoDiff(sut.validatedPhone, "+7 911 777-77-77")
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 777-77-77")))

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
        XCTAssertNoDiff(sut.banksPrefferdSection?.phone.value, "Abc")
        XCTAssertNoDiff(sut.banksSection?.phone.value, "Abc")
    }
    
    func test_textFieldChange_shouldNotChangeMode_onFastPayments_banksAndCountries_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        scheduler.advance(by: 300)
        
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))

        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_textFieldChange_shouldChangeContactsFilter_onSelect_contacts_nilText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        
        sut.typeAndWait(nil, on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
    }
    
    func test_textFieldChange_shouldChangeContactsFilter_onSelect_contacts_emptyText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        
        sut.typeAndWait("", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "")
    }
    
    func test_textFieldChange_shouldChangeContactsFilter_onSelect_contacts_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "+7 911")
    }
    
    func test_textFieldChange_shouldChangeContactsFilter_onSelect_contacts_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "+7 911 111-11-11")

        sut.typeAndWait("Abc", on: scheduler)
        
        XCTAssertNoDiff(sut.contactsSection?.filter.value, "Abc")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banks_nilText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait(nil, on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banks_emptyText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banks_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "+7 911")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banks_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "+7 911 111 11 11")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banksFullInfo_nilText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait(nil, on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banksFullInfo_emptyText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banksFullInfo_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "+7 911")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_banksFullInfo_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(sut.banksSection?.filter.value, "+7 911 111 11 11")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_countries_nilText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)
        
        sut.typeAndWait(nil, on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_countries_emptyText() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)
        
        sut.typeAndWait("", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, "")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_countries_invalidPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, "+7 911")
    }
    
    func test_textFieldChange_shouldChangeBankSectionFilter_onSelect_countries_validPhone() {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, nil)
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(sut.countriesSection?.filter.value, "+7 911 111 11 11")
    }
    
    // MARK: - section actions
    
    func test_shouldSendPaymentRequestedAction_onLatestPaymentsItemDidTapped() throws {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let latestPaymentId = 123
        section.action.send(ContactsSectionViewModelAction.LatestPayments.ItemDidTapped(latestPaymentId: latestPaymentId))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [latestPaymentId])
    }
    
    func test_shouldSendContactPhoneSelectedAction_onContactsItemDidTapped_onSelect_emptyPhone() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let contactPhoneSelectedPublisher = sut.action
            .compactMap({ $0 as? ContactsViewModelAction.ContactPhoneSelected })
            .map(\.phone)
        let spy = ValueSpy(contactPhoneSelectedPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Contacts.ItemDidTapped(phone: ""))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values, [""])
    }
    
    func test_shouldChangeTextToFormatted_onContactsItemDidTapped_onFastPayments_onEmpty() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let section = try XCTUnwrap(sut.firstSection)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.searchText, nil)
        
        section.action.send(ContactsSectionViewModelAction.Contacts.ItemDidTapped(phone: ""))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(sut.searchText, "")
    }
    
    func test_shouldPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_sfp_phone() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 0115110217", on: scheduler)

        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }

    func test_shouldPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_sfp_mixed() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("Abc 0115110217", on: scheduler)

        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }

    func test_shouldNotSendPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_sfp_text() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("Abc", on: scheduler)

        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }

    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onBanksPrefferedItemDidTapped_abroad_sfp() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertFalse(sut.phoneIsValid)
        XCTAssertNoDiff(spy.values, [])
    }

    func test_shouldNotSendPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_direct_phone() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "+7 911 111 11 11"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_shouldNotSendPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_direct_mixed() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "Abc 911 111 11 11"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_shouldNotSendPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_direct_text() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "Abc"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_shouldNotSendPaymentRequestedAction_onBanksPrefferedItemDidTapped_abroad_direct_invalidPhone() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "+7 911 111 11 11"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onBanksPrefferedItemDidTapped_abroad_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
                
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldNotSendPaymentRequestedActionOnMissingBank_onBanksPrefferedItemDidTapped_abroad_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "+7 911 111 11 11"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(model.hasBank(withID: bankID))
    }
    
    func test_shouldNotSendPaymentRequestedActionOnMissingCountry_onBanksPrefferedItemDidTapped_abroad_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.abroad)
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        let phone = "+7 911 111 11 11"
        sut.typeAndWait(phone, on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(model.hasCountry(withID: countryID))
    }
    
    func test_shouldSendPaymentRequestedAction_onBanksItemDidTapped_fastPayments_sfp() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        XCTAssertNoDiff(spy.values, [.test])
        XCTAssertTrue(sut.phoneIsValid)
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onBanksItemDidTapped_fastPayments_sfp() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .sfp)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldNotSendPaymentRequestedActionOnMissingBank_onBanksItemDidTapped_fastPayments_sfp() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.mockPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(model.hasBank(withID: bankID))
    }
    
    func test_shouldSendPaymentRequestedAction_onBanksItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
                
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertTrue(sut.phoneIsValid)
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        XCTAssertNoDiff(spy.values, [.init(phone: "+7 911 111-11-11", countryID: countryID)])
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onBanksItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldNotSendPaymentRequestedActionOnMissingBank_onBanksItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        let countryID = "RUS"
        try model.addDummyCountry(id: countryID, paymentSystem: .direct)
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        XCTAssertTrue(sut.phoneIsValid)
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(model.hasBank(withID: bankID))
    }
    
    func test_shouldNotSendPaymentRequestedActionOnMissingCountry_onBanksItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, model) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        try model.addDummyBank(id: bankID, bankType: .direct)
        
        let countryID = "RUS"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        sut.typeAndWait("+7 911 111 11 11", on: scheduler)
        
        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(model.hasCountry(withID: countryID))
    }
    
    func test_shouldSendBankSelectedAction_onBanksItemDidTapped_select_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.action.compactMap { $0 as? ContactsViewModelAction.BankSelected })
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values.map(\.bankId), [])

        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values.map(\.bankId), [bankID])
    }
    
    func test_shouldSendBankSelectedAction_onBanksItemDidTapped_select_banks() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.action.compactMap { $0 as? ContactsViewModelAction.BankSelected })
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(spy.values.map(\.bankId), [])

        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(spy.values.map(\.bankId), [bankID])
    }
    
    func test_shouldSendBankSelectedAction_onBanksItemDidTapped_select_banksFullInfo() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.action.compactMap { $0 as? ContactsViewModelAction.BankSelected })
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(spy.values.map(\.bankId), [])

        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(spy.values.map(\.bankId), [bankID])
    }
    
    func test_shouldSendBankSelectedAction_onBanksItemDidTapped_select_countries() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.action.compactMap { $0 as? ContactsViewModelAction.BankSelected })
        let section = try XCTUnwrap(sut.firstSection)
        
        let bankID = "bankID"
        
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(spy.values.map(\.bankId), [])

        section.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bankID))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(spy.values.map(\.bankId), [bankID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)

        sut.typeAndWait("+7 911 111 11 11", on: scheduler)

        XCTAssertNoDiff(spy.values, [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [.init(phone: "+7 911 111-11-11", countryID: countryID)])
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onCountriesItemDidTapped_fastPayments_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.directPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)

        XCTAssertNoDiff(spy.values, [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.contacts))
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_fastPayments_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentDataID: LatestPaymentData.ID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentDataID)

        sut.typeAndWait("+7 911 111 11 11", on: scheduler)

        XCTAssertNoDiff(spy.values, [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [latestPaymentDataID])
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onCountriesItemDidTapped_fastPayments_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentDataID: LatestPaymentData.ID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentDataID)

        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_fastPayments_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        sut.typeAndWait("+7 911 111 11 11", on: scheduler)

        XCTAssertNoDiff(spy.values, [])
        XCTAssertNoDiff(sut.mode, .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11")))
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldNotSendPaymentRequestedActionOnInvalidPhone_onCountriesItemDidTapped_fastPayments_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertFalse(sut.phoneIsValid)
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_abroad() throws {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(sut.mode, .abroad)
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_contacts_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.countryIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)

        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [countryID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banks_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.countryIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)
        
        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [countryID])    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banksFullInfo_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.countryIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)
        
        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [countryID])    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_countries_direct() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.countryIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)
        
        let countryID = "RUS"
        let source: Payments.Operation.Source = .direct(countryId: countryID)
        
        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [countryID])    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_contacts_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banks_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banksFullInfo_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_countries_template() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.paymentTemplateDataIDPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let paymentTemplateDataID = 123
        let source: Payments.Operation.Source = .template(paymentTemplateDataID)

        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [paymentTemplateDataID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_contacts_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentID)

        XCTAssertNoDiff(sut.mode, .select(.contacts))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [latestPaymentID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banks_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentID)

        XCTAssertNoDiff(sut.mode, .select(.banks(phone: nil)))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [latestPaymentID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_banksFullInfo_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentID)

        XCTAssertNoDiff(sut.mode, .select(.banksFullInfo))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [latestPaymentID])
    }
    
    func test_shouldSendPaymentRequestedAction_onCountriesItemDidTapped_select_countries_latestPayment() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.latestPaymentPublisher)
        let section = try XCTUnwrap(sut.firstSection)

        let latestPaymentID = 123
        let source: Payments.Operation.Source = .latestPayment(latestPaymentID)

        XCTAssertNoDiff(sut.mode, .select(.countries))
        XCTAssertNoDiff(spy.values, [])
        
        section.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [latestPaymentID])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_abroad() throws {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_fastPayments_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_fastPayments_banksAndCountries() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_select_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
            [.contacts],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_select_banks() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_select_banksFullInfo() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldRemoveCountriesFromVisible_onCollapsableHideCountries_select_countries() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.HideCountries())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
            [],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_abroad() throws {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments, .countries],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_fastPayments_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_fastPayments_banksAndCountries() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_select_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
            [.contacts],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_select_banks() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_select_banksFullInfo() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldChangeVisible_onCollapsableResetSections_select_countries() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
            [.countries],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_abroad() throws {
        
        let (sut, scheduler, _) = makeSUT(.abroad)
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments, .countries],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .countries],
            [.latestPayments, .countries],
            [.countries],
        ])
    }

    func test_shouldChangeVisible_onContactsDidScroll_fastPayments_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.contacts],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_fastPayments_banksAndCountries() throws {
        
        let (sut, scheduler, _) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banksPreferred, .banks, .countries],
            [.latestPayments, .contacts],
            [.latestPayments, .contacts],
            [.contacts],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_select_contacts() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.contacts))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
            [.contacts],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.contacts],
            [.contacts],
            [.contacts],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_select_banks() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banks(phone: nil)))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_select_banksFullInfo() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.banksFullInfo))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: true))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
        ])
        
        section.action.send(ContactsViewModelAction.ContactsDidScroll(isVisible: false))
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.banks],
            [.banks],
            [.banks],
        ])
    }
    
    func test_shouldChangeVisible_onContactsDidScroll_select_countries() throws {
        
        let (sut, scheduler, _) = makeSUT(.select(.countries))
        let spy = ValueSpy(sut.$visible.map { $0.map(\.type) })
        let section = try XCTUnwrap(sut.firstSection)

        scheduler.advance(by: 300)

        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
            [.countries],
        ])
        
        section.action.send(ContactsSectionViewModelAction.Collapsable.ResetSections())
        scheduler.advance(by: 300)
        
        XCTAssertNoDiff(spy.values, [
            [],
            [.countries],
            [.countries],
            [.countries],
        ])
    }
    
    // MARK: - sections for mode
    
    func test_sectionsForModeShouldCreateSections_fastPayments_contacts() {
        
        let mode: ContactsViewModel.Mode = .fastPayments(.contacts)
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNotNil(sections.latestPayments)
        XCTAssertNotNil(sections.contactsSection)
        XCTAssertNotNil(sections.banksPrefferdSection)
        XCTAssertNotNil(sections.banksSection)
        XCTAssertNotNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_fastPayments_banksAndCountries() {
        
        let mode: ContactsViewModel.Mode = .fastPayments(.banksAndCountries(phone: "+7 911 111-11-11"))
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNotNil(sections.latestPayments)
        XCTAssertNotNil(sections.contactsSection)
        XCTAssertNotNil(sections.banksPrefferdSection)
        XCTAssertNotNil(sections.banksSection)
        XCTAssertNotNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_abroad() {
        
        let mode: ContactsViewModel.Mode = .abroad
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNotNil(sections.latestPayments)
        XCTAssertNil(sections.contactsSection)
        XCTAssertNil(sections.banksPrefferdSection)
        XCTAssertNil(sections.banksSection)
        XCTAssertNotNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_select_contacts() {
        
        let mode: ContactsViewModel.Mode = .select(.contacts)
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNil(sections.latestPayments)
        XCTAssertNotNil(sections.contactsSection)
        XCTAssertNil(sections.banksPrefferdSection)
        XCTAssertNil(sections.banksSection)
        XCTAssertNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_select_banks() {
        
        let mode: ContactsViewModel.Mode = .select(.banks(phone: nil))
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNil(sections.latestPayments)
        XCTAssertNil(sections.contactsSection)
        XCTAssertNil(sections.banksPrefferdSection)
        XCTAssertNotNil(sections.banksSection)
        XCTAssertNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_select_banksFullInfo() {
        
        let mode: ContactsViewModel.Mode = .select(.banksFullInfo)
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNil(sections.latestPayments)
        XCTAssertNil(sections.contactsSection)
        XCTAssertNil(sections.banksPrefferdSection)
        XCTAssertNotNil(sections.banksSection)
        XCTAssertNil(sections.countriesSection)
    }
    
    func test_sectionsForModeShouldCreateSections_select_countries() {
        
        let mode: ContactsViewModel.Mode = .select(.countries)
        let model: Model = .mockWithEmptyExcept()
        
        let sections = model.sections(for: mode)
        
        XCTAssertNil(sections.latestPayments)
        XCTAssertNil(sections.contactsSection)
        XCTAssertNil(sections.banksPrefferdSection)
        XCTAssertNil(sections.banksSection)
        XCTAssertNotNil(sections.countriesSection)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ mode: ContactsViewModel.Mode,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ContactsViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let scheduler = DispatchQueue.test
        let sut = model.makeContactsViewModel(
            forMode: mode,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        // TODO: Investigate memory leak
        // trackForMemoryLeaks(sut, file: file, line: line)
        //trackForMemoryLeaks(scheduler, file: file, line: line)
        //trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, scheduler, model)
    }
}

extension Model {
    
    static func mockWithEmptyExcept(
        sessionAgent: SessionAgentProtocol = SessionAgentEmptyMock(),
        serverAgent: ServerAgentProtocol = ServerAgentEmptyMock(),
        localAgent: LocalAgentProtocol = LocalAgentEmptyMock(),
        keychainAgent: KeychainAgentProtocol = KeychainAgentMock(),
        settingsAgent: SettingsAgentProtocol = SettingsAgentMock(),
        biometricAgent: BiometricAgentProtocol = BiometricAgentMock(),
        locationAgent: LocationAgentProtocol = LocationAgentMock(),
        contactsAgent: ContactsAgentProtocol = ContactsAgentMock(),
        cameraAgent: CameraAgentProtocol = CameraAgentMock(),
        imageGalleryAgent: ImageGalleryAgentProtocol = ImageGalleryAgentMock(),
        networkMonitorAgent: NetworkMonitorAgentProtocol = NetworkMonitorAgentMock()
    ) -> Model {
        
        .init(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent,
            localAgent: localAgent,
            keychainAgent: keychainAgent,
            settingsAgent: settingsAgent,
            biometricAgent: biometricAgent,
            locationAgent: locationAgent,
            contactsAgent: contactsAgent,
            cameraAgent: cameraAgent,
            imageGalleryAgent: imageGalleryAgent,
            networkMonitorAgent: networkMonitorAgent
        )
    }
}

// MARK: DSL during refactoring

extension Model {
    
    func hasBank(withID bankID: BankData.ID) -> Bool {
        
        bankList.value.contains(where: { $0.id == bankID })
    }
    
    func hasCountry(withID countryID: CountryData.ID) -> Bool {
        
        countriesList.value.contains(where: { $0.id == countryID })
    }
    
    func addDummyBank(
        id: String,
        bankType: BankType,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let dummyBank = BankData.dummy(id: id, bankType: bankType)
        bankList.value.append(dummyBank)
        
        let bank = try XCTUnwrap(bankList.value.first(where: { $0.id == id }), file: file, line: line)
        XCTAssertEqual(bank.bankType, bankType, file: file, line: line)
    }
    
    func addDummyCountry(
        id: String,
        paymentSystem: CountryData.PaymentSystem,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let dummyCountry = CountryData.dummy(id: id, paymentSystem: paymentSystem)
        countriesList.value.append(dummyCountry)
        
        let country = try XCTUnwrap(countriesList.value.first(where: { $0.id == id }), file: file, line: line)
        XCTAssertEqual(country.paymentSystemIdList, [paymentSystem], file: file, line: line)
    }
}

extension ContactsViewModel {
    
    // MARK: - DSL
    
    var keyboardType: UIKeyboardType? {
        
        searchFieldModel.keyboardType.uiKeyboardType
    }
    
    var phoneIsValid: Bool { validatedPhone != nil }
    
    var searchAction: AnyPublisher<TextViewPhoneNumberView.ViewModel.State, Never> {
    
        searchFieldModel.phoneNumberStatePublisher
            .dropFirst()
            .eraseToAnyPublisher()
    }
    
    var searchText: String? { searchFieldModel.text }
    
    var textFieldStateCase: TextViewPhoneNumberView.ViewModel.State {
     
        searchFieldModel.phoneNumberState
    }
    
    var textFieldModelStateCase: TextViewPhoneNumberView.ViewModel.State {
     
        searchFieldModel.phoneNumberState
    }
    
    var textFieldModelText: String? {
     
        searchFieldModel.text
    }
    
    func typeAndWait(
        _ text: String?,
        on scheduler: TestSchedulerOfDispatchQueue,
        by milliseconds: Int = 300
    ) {
        searchFieldModel.setText(to: text)
        scheduler.advance(by: .milliseconds(milliseconds))
    }
    
    func setModeAndWait(
        _ mode: ContactsViewModel.Mode,
        on scheduler: TestSchedulerOfDispatchQueue,
        by milliseconds: Int = 300
    ) {
        setMode(to: mode)
        scheduler.advance(by: .milliseconds(milliseconds))
    }
    
    func activateTextFieldAndWait(
        on scheduler: TestSchedulerOfDispatchQueue,
        by milliseconds: Int = 300
    ) {
        searchFieldModel.startEditing()
        scheduler.advance(by: .milliseconds(milliseconds))
    }
    
    func deactivateTextFieldAndWait(
        on scheduler: TestSchedulerOfDispatchQueue,
        by milliseconds: Int = 300
    ) {
        searchFieldModel.finishEditing()
        scheduler.advance(by: .milliseconds(milliseconds))
    }
    
    // MARK: - Helpers
    
    var countryIDPublisher: AnyPublisher<CountryData.ID, Never> {
        
        action
            .compactMap({ $0 as? ContactsViewModelAction.CountrySelected })
            .map(\.countryId)
            .eraseToAnyPublisher()
    }
    
    var directPublisher: AnyPublisher<Payments.Operation.Source.Direct?, Never> {

        action
            .compactMap { $0 as? ContactsViewModelAction.PaymentRequested }
            .map(\.source.direct)
            .eraseToAnyPublisher()
    }
    
    var latestPaymentPublisher: AnyPublisher<LatestPaymentData.ID?, Never> {
        
        action
            .compactMap { $0 as? ContactsViewModelAction.PaymentRequested }
            .map(\.source.latestPayment)
            .eraseToAnyPublisher()
    }
    
    var mockPublisher: AnyPublisher<Payments.Mock?, Never> {
        
        action
            .compactMap { $0 as? ContactsViewModelAction.PaymentRequested }
            .map(\.source.mock)
            .eraseToAnyPublisher()
    }
    
    var paymentTemplateDataIDPublisher: AnyPublisher<PaymentTemplateData.ID?, Never> {

        action
            .compactMap { $0 as? ContactsViewModelAction.PaymentRequested }
            .map(\.source.paymentTemplateDataID)
            .eraseToAnyPublisher()
    }
    
    var isLastPaymentsSectionVisible: Bool {
        
        !visible
            .compactMap({ $0 as? ContactsLatestPaymentsSectionViewModel })
            .isEmpty
    }
}

extension BankData {
    
    static func dummy(
        id: String,
        bankType: BankType,
        bankCountry: String = "RUS"
    ) -> Self {
        
        .init(
            memberId: id,
            memberName: "any",
            memberNameRus: "any",
            paymentSystemCodeList: [bankType.rawValue.uppercased()],
            md5hash: "",
            svgImage: .init(description: ""),
            bankCountry: bankCountry
        )
    }
}

extension CountryData {
    
    static func dummy(
        id: String,
        paymentSystem: CountryData.PaymentSystem,
        bankCountry: String = "RUS"
    ) -> Self {
        
        .init(
            code: id,
            contactCode: nil,
            md5hash: nil,
            name: id,
            paymentSystemIdList: [paymentSystem],
            sendCurr: "RUB",
            svgImage: nil
        )
    }
}

extension Payments.Operation.Source {
    
    struct Direct: Equatable {
        
        let phone: String?
        let countryID: CountryData.ID
    }
    
    var direct: Direct? {
        
        switch self {
        case let .direct(phone: phone, countryId: countryID, _):
            return .init(phone: phone, countryID: countryID)
            
        default:
            return nil
        }
    }
    
    var latestPayment: LatestPaymentData.ID? {
        
        switch self {
        case let .latestPayment(id):
            return id
            
        default:
            return nil
        }
    }
    
    var mock: Payments.Mock? {
        
        switch self {
        case let .mock(mock):
            return mock
            
        default:
            return nil
        }
    }
    
    var paymentTemplateDataID: PaymentTemplateData.ID? {
        
        switch self {
        case let .template(id):
            return id
            
        default:
            return nil
        }
    }
}

extension Payments.Mock {
    
    static let test: Self = .init(service: .sfp, parameters: [
        .init(id: "RecipientID", value: "+7 0115110217"),
        .init(id: "BankRecipientID", value: "1crt88888881"),
    ])
}
