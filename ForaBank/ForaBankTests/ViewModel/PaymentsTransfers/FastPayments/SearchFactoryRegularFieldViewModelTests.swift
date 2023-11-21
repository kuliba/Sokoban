//
//  SearchFactoryRegularFieldViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2023.
//

@testable import ForaBank
import TextFieldDomain
import XCTest

final class SearchFactoryRegularFieldViewModelTests: XCTestCase {

    func test_insertAtNotEnd_shouldNotMoveCursorToEnd_fastPayments_contacts() {
        
        let (sut, scheduler, spy) = makeSUT(.fastPayments(.contacts))

        sut.startEditing()
        XCTAssertNoDiff(spy.values, [
            .placeholder("Выберите контакт"),
        ])
        
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .placeholder("Выберите контакт"),
            .editing(.init("", cursorAt: 0)),
        ])
        
        sut.type("7916", in: .zero)
        scheduler.advance()
        XCTAssertNoDiff(spy.values, [
            .placeholder("Выберите контакт"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("+7 916", cursorAt: 6)),
        ])
        
        sut.insert("8", atCursor: 2)
        scheduler.advance()
        XCTExpectFailure("cursor should be at position 3 but jumps to the end")
        XCTAssertNoDiff(spy.values, [
            .placeholder("Выберите контакт"),
            .editing(.init("", cursorAt: 0)),
            .editing(.init("+7 916", cursorAt: 6)),
            .editing(.init("+72 916", cursorAt: 3)),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RegularFieldViewModel
    
    private func makeSUT(
        _ mode: ContactsViewModel.Mode,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RegularFieldViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<TextFieldState>
    ) {
        let scheduler = DispatchQueue.test
        let sut = SearchFactory.makeSearchFieldModel(
            for: mode,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, spy)
    }
}
