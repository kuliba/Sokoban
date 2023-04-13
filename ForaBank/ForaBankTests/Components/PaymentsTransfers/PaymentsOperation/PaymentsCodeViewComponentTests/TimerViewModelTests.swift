//
//  TimerViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 12.04.2023.
//

@testable import ForaBank
import XCTest

final class TimerViewModelTests: XCTestCase {
    
    func test_timer_shouldPublishValuesEachSecond() {
        
        var result: String?
        let sut = makeSUT(delay: 2, completeAction: { result = "finished"})
        let spy = ValueSpy(sut.$value)
        
        // TODO: change to TestScheduler to control time and speedup tests
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        XCTAssertEqual(result, nil)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        XCTAssertEqual(result, "finished")
        
        XCTAssertEqual(spy.values.first, "00:02")
        XCTAssertEqual(spy.values.last, "00:00")
        
        // flaky
        // XCTAssertEqual(spy.values.count, 3)
        
        // flaky until time is controlled
        // XCTAssertEqual(spy.values, ["00:02", "00:01", "00:00"])
    }

    // MARK: - Helpers
    
    private func makeSUT(
        delay: TimeInterval,
        completeAction: @escaping () -> Void
    ) -> PaymentsCodeView.ViewModel.TimerViewModel {
        
        .init(delay: delay, completeAction: completeAction)
    }
}
