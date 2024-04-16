//
//  SearchFactoryTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.05.2023.
//

@testable import ForaBank
import XCTest

final class SearchFactoryTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetInitialValues_abroad() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.abroad)
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_fastPayments_contacts() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.contacts))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_empty() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.banksAndCountries(phone: "")))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_invalidPhone() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.banksAndCountries(phone: "123")))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_fastPayments_banksAndCountries_validPhone() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.banksAndCountries(phone: "+7 911 111 11 11")))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_select_contacts() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.contacts))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_select_banks() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.banks(phone: nil)))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_select_banksFullInfo() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.banksFullInfo))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    func test_init_shouldSetInitialValues_select_countries() {
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.countries))
        
        scheduler.advance()
        
        XCTAssertEqual(sut.text, nil)
        XCTAssertEqual(sut.phoneNumberState, .idle)
        XCTAssertEqual(textSpy.values, [nil])
        XCTAssertEqual(stateSpy.values, [.idle])
    }
    
    // MARK: - fastPayments - contacts
    
    func test_shouldReplacePrefix8_fastPayments_contacts() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.contacts))
        scheduler.advance()
        
        sut.setText(to: "8")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+8")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+8"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }

    func test_shouldReplacePrefixStartingWith8_fastPayments_contacts() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.contacts))
        scheduler.advance()
        
        sut.setText(to: "8916")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+7 916")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+7 916"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }

    func test_shouldNotReplacePrefix2_fastPayments_contacts_typeOther() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.fastPayments(.contacts))
        scheduler.advance()
        
        sut.setText(to: "2916")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+291 6")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+291 6"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }

    // \u{FEFF} — неразрывный пробел нулевой ширины (BOM).
    // \u{00a0} — неразрывный пробел.
    func test_cleanup_shouldRemoveBOM_fastPayments_contacts() {
        
      let (sut, scheduler, textSpy, _) = makeSUT(.fastPayments(.contacts))

      let textWithBOM = "\u{00a0}+7 919 123‑45‑67"
      let expectedResult = "+7 919 123-45-67"

      sut.setText(to: textWithBOM)
      scheduler.advance()

      XCTAssertEqual(textSpy.values, [nil, expectedResult])
    }

    func test_cleanup_shouldRemoveNewline_fastPayments_contacts() {
      let (sut, scheduler, textSpy, _) = makeSUT(.fastPayments(.contacts))

      let textWithNewline = "+7\n919 123‑45‑67"
      let expectedResult = "+7 919 123-45-67"

      sut.setText(to: textWithNewline)
      scheduler.advance()

      XCTAssertEqual(textSpy.values, [nil, expectedResult])
    }

    func test_cleanup_shouldReplaceOptionProbes_fastPayments_contacts() {
      let (sut, scheduler, textSpy, _) = makeSUT(.fastPayments(.contacts))

      let textWithOptionProbes = "+7\u{00a0}919\u{00a0}123‑45‑67"
      let expectedResult = "+7 919 123-45-67"

      sut.setText(to: textWithOptionProbes)
      scheduler.advance()

      XCTAssertEqual(textSpy.values, [nil, expectedResult])
    }

    func test_cleanup_shouldCombine_fastPayments_contacts() {
      let (sut, scheduler, textSpy, _) = makeSUT(.fastPayments(.contacts))

      let textWithAll = "\u{FEFF}+7\n 919 123‑45‑67"
      let expectedResult = "+7 919 123-45-67"

      sut.setText(to: textWithAll)
      scheduler.advance()

      XCTAssertEqual(textSpy.values, [nil, expectedResult])
    }

    // MARK: - select - contacts
    
    func test_shouldReplacePrefix8_select_contacts() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.contacts))
        scheduler.advance()
        
        sut.setText(to: "8")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+8")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+8"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }

    func test_shouldReplacePrefixStartingWith8_select_contacts() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.contacts))
        scheduler.advance()
        
        sut.setText(to: "8916")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+7 916")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+7 916"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }

    func test_shouldNotReplacePrefix2_select_contacts() {
       
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.contacts))
        scheduler.advance()
        
        sut.setText(to: "2916")
        scheduler.advance()

        XCTAssertNoDiff(sut.text, "+291 6")
        XCTAssertNoDiff(sut.phoneNumberState, .selected)
        XCTAssertNoDiff(textSpy.values, [nil, "+291 6"])
        XCTAssertNoDiff(stateSpy.values, [.idle, .selected])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ mode: ContactsViewModel.Mode,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any PhoneNumberTextFieldViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        textSpy: ValueSpy<String?>,
        stateSpy: ValueSpy<TextViewPhoneNumberView.ViewModel.State>
    ) {
        let scheduler = DispatchQueue.test
        let sut = SearchFactory.makeSearchFieldModel(
            for: mode, 
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        let textSpy = ValueSpy(sut.textPublisher)
        let stateSpy = ValueSpy(sut.phoneNumberStatePublisher)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(textSpy, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, scheduler, textSpy, stateSpy)
    }
}
