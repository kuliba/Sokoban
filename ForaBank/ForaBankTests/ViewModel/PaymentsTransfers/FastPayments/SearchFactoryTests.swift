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
        
        let (sut, scheduler, textSpy, stateSpy) = makeSUT(.select(.banks))
        
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
