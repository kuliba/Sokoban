//
//  QRSearchCityViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.05.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class QRSearchCityViewModelTests: XCTestCase {
    
    func test_initShouldSetTitle() {
        
        let (sut, _, scheduler, spy) = makeSUT()
        
        XCTAssertEqual(sut.title, "Выберите регион")
        XCTAssertNoDiff(spy.values, [])
        
        scheduler.advance(by: .milliseconds(300))
        
        XCTAssertNoDiff(spy.values, [.all(.test)])
    }
    
    func test_textFieldChangeShouldChangeRegionsState() {
        
        let (sut, textField, scheduler, spy) = makeSUT()
        
        scheduler.advance(by: .milliseconds(300))
        
        XCTAssertNoDiff(spy.values, [
            .all(.test)
        ])
        XCTAssertNoDiff(
            sut.state.regionsToDisplay,
            .test
        )
        
        setText("A", textField, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all(.test),
            .filtered(.test.dropLast()),
        ])
        XCTAssertNoDiff(
            sut.state.regionsToDisplay,
            .test.dropLast()
        )
        
        setText("Aa", textField, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all(.test),
            .filtered(.test.dropLast()),
            .filtered(.test.dropLast(2)),
        ])
        XCTAssertNoDiff(
            sut.state.regionsToDisplay,
            .test.dropLast(2)
        )
        
        setText(nil, textField, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all(.test),
            .filtered(.test.dropLast()),
            .filtered(.test.dropLast(2)),
            .all(.test),
        ])
        XCTAssertNoDiff(
            sut.state.regionsToDisplay,
            .test
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        regions: [String] = .test,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: QRSearchCityViewModel,
        textField: RegularFieldViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<RegionsState>
    ) {
        let scheduler = DispatchQueue.test
        let textField = TextFieldFactory.makeTextField(
            text: nil,
            placeholderText: "Выберите регион",
            keyboardType: .default,
            limit: nil,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let searchViewModel = SearchBarView.ViewModel(
            textFieldModel: textField,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = QRSearchCityViewModel(
            regions: .test,
            searchViewModel: searchViewModel,
            scheduler: scheduler.eraseToAnyScheduler(),
            select: { _ in }
        )
        let spy = ValueSpy(sut.$state.dropFirst())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(textField, file: file, line: line)
        trackForMemoryLeaks(searchViewModel, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, textField, scheduler, spy)
    }
    
    // MARK: - DSL
    
    private func setText(
        _ text: String?,
        _ textField: any PhoneNumberTextFieldViewModel,
        on scheduler: TestSchedulerOfDispatchQueue,
        by milliseconds: Int = 300
    ) {
        textField.setText(to: text)
        scheduler.advance(by: .milliseconds(milliseconds))
    }
}

private extension Array where Element == String {
    
    static let test: Self = [
        "Aaaa",
        "AAaa",
        "Abbb",
        "Bbbb"
    ]
}
