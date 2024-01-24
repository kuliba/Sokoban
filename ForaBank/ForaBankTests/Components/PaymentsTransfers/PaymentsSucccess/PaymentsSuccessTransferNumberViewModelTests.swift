//
//  PaymentsSuccessTransferNumberViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.11.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsSuccessTransferNumberViewModelTests: XCTestCase {
    
    func test_init_shouldSetTitle() {
        
        let title = UUID().uuidString
        let (sut, _) = makeSUT(makeSuccessTransferNumber(number: title))
        
        XCTAssertNoDiff(sut.title, title)
    }
    
    func test_init_shouldSetStateToCopy() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.values, [.copy])
    }
    
    func test_copyButtonDidTapped_shouldSetStateToCheck() {
        
        let (sut, spy) = makeSUT()
        
        sut.copyButtonDidTapped()
        
        XCTAssertNoDiff(spy.values, [.copy, .check])
    }
    
    func test_copyButtonDidTapped_shouldSetStateBackToCopyAfterSpecifiedInterval() {
        
        let (sut, spy) = makeSUT(timeoutMS: 100)
        
        sut.copyButtonDidTapped()
        XCTAssertNoDiff(spy.values, [.copy, .check])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.09)
        XCTAssertNoDiff(spy.values, [.copy, .check])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.01)
        XCTAssertNoDiff(spy.values, [.copy, .check, .copy])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsSuccessTransferNumberView.ViewModel
    
    private func makeSUT(
        _ source: Payments.ParameterSuccessTransferNumber = makeSuccessTransferNumber(),
        timeoutMS: Int = 300,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<SUT.State>
    ) {
        
        let sut = SUT(source, timeoutMS: timeoutMS)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private func makeSuccessTransferNumber(
    number: String = UUID().uuidString
) -> Payments.ParameterSuccessTransferNumber {

    .init(number: number)
}
