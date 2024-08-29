//
//  OperationTrackerModelTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import CombineSchedulers
import ForaTools
import PayHub
import XCTest

final class OperationTrackerModelTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
    
        let (_, stateSpy, _) = makeSUT(initialState: .failure)
        
        XCTAssertNoDiff(stateSpy.values, [.failure])
    }
    
    func test_start_shouldChangeState_failure() {
    
        let (sut, stateSpy, startSpy) = makeSUT()
        
        sut.event(.start)
        startSpy.complete(with: .failure(anyError()))
        
        XCTAssertNoDiff(stateSpy.values, [
            .notStarted,
            .inflight,
            .failure
        ])
    }

    func test_start_shouldChangeState_success() {
    
        let (sut, stateSpy, startSpy) = makeSUT()
        
        sut.event(.start)
        startSpy.complete(with: .success(makeResponse()))
        
        XCTAssertNoDiff(stateSpy.values, [
            .notStarted,
            .inflight,
            .success
        ])
    }

    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerModel
    private typealias StateSpy = ValueSpy<OperationTrackerState>
    private typealias StartSpy = Spy<Void, Result<Response, Error>>
    
    private func makeSUT(
        initialState: OperationTrackerState = .notStarted,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        startSpy: StartSpy
    ) {
        let startSpy = StartSpy()
        let sut = SUT(
            initialState: initialState,
            start: startSpy.process(completion:),
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(startSpy, file: file, line: line)
        
        return (sut, stateSpy, startSpy)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
}
