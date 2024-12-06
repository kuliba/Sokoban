//
//  PaymentsSuccessTransferNumberViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 25.11.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsSuccessTransferNumberViewModelTests: XCTestCase {
    
    func test_init_shouldSetTitle() {
        
        let title = UUID().uuidString
        let (sut, _,_) = makeSUT(makeSuccessTransferNumber(number: title))
        
        XCTAssertNoDiff(sut.title, title)
    }
    
    func test_init_shouldSetStateToCopy() {
        
        let (_, spy,_) = makeSUT()
        
        XCTAssertNoDiff(spy.values, [.copy])
    }
    
    func test_copyButtonDidTapped_shouldSetStateToCheck() {
        
        let (sut, spy,_) = makeSUT()
        
        sut.copyButtonDidTapped()
        
        XCTAssertNoDiff(spy.values, [.copy, .check])
    }
    
    func test_copyButtonDidTapped_shouldSetStateBackToCopyAfterSpecifiedInterval() {
        
        let (sut, spy, scheduler) = makeSUT(timeout: .milliseconds(100))
        
        sut.copyButtonDidTapped()
        XCTAssertNoDiff(spy.values, [.copy, .check])
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(99))))
        XCTAssertNoDiff(spy.values, [.copy, .check])
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(100))))
        XCTAssertNoDiff(spy.values, [.copy, .check, .copy])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsSuccessTransferNumberView.ViewModel
    
    private func makeSUT(
        _ source: Payments.ParameterSuccessTransferNumber = makeSuccessTransferNumber(),
        timeout: SUT.Timeout = .milliseconds(300),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<SUT.State>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(
            source,
            timeout: timeout,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
}

private func makeSuccessTransferNumber(
    number: String = UUID().uuidString
) -> Payments.ParameterSuccessTransferNumber {

    .init(number: number)
}
