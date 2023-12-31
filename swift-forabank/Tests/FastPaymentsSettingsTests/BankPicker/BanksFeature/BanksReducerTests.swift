//
//  BanksReducerTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import XCTest

final class BanksReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, applySelectionSpy) = makeSUT()
        
        XCTAssertNoDiff(applySelectionSpy.callCount, 0)
    }
    
    func test_reduce_shouldCallApplySelectionWithSelectedBankIDsOnApplySelection() {
        
        let state = anyState()
        let event = makeApplySelection(.c, .a)
        let (sut, applySelectionSpy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(applySelectionSpy.payloads, [
            .init([Bank.c, .a].map(\.id))
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BanksReducer
    private typealias ApplySelectionSpy = CallSpy<Set<Bank.ID>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        applySelectionSpy: ApplySelectionSpy
    ) {
        let applySelectionSpy = ApplySelectionSpy()
        let sut = SUT(applySelection: applySelectionSpy.call(payload:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(applySelectionSpy, file: file, line: line)
        
        return (sut, applySelectionSpy)
    }
    
    private func anyState() -> Banks {
        
        .stub(
            all: [.d, .b, .a, .c],
            selected: [.b, .d]
        )
    }
    
    private func makeApplySelection(
        _ banks: Bank...
    ) -> BanksEvent {
        
        .applySelection(.init(banks.map(\.id)))
    }
}
