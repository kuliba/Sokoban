//
//  BanksReducerTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import FastPaymentsSettings
import XCTest

final class BanksReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, applySelectionSpy) = makeSUT()
        
        XCTAssertNoDiff(applySelectionSpy.callCount, 0)
    }
    
    func test_reduce_shouldCallApplySelectionWithEmptySelectedBankIDsOnApplySelection() {
        
        let state = anyState()
        let event: BanksEvent = .applySelection(makeIDs())
        let (sut, applySelectionSpy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(applySelectionSpy.payloads, [makeIDs()])
    }
    
    func test_reduce_shouldCallApplySelectionWithOneSelectedBankIDsOnApplySelection() {
        
        let state = anyState()
        let event: BanksEvent = .applySelection(makeIDs(.c))
        let (sut, applySelectionSpy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(applySelectionSpy.payloads, [makeIDs(.c)])
    }
    
    func test_reduce_shouldCallApplySelectionWithSelectedBankIDsOnApplySelection() {
        
        let state = anyState()
        let event: BanksEvent = .applySelection(makeIDs(.c, .a))
        let (sut, applySelectionSpy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(applySelectionSpy.payloads, [makeIDs(.c, .a)])
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
    
    private func anyState(
        all allBanks: [Bank] = [.d, .b, .a, .c],
        selected: [Bank] = [.b, .d]
    ) -> Banks {
        
        .stub(
            all: allBanks,
            selected: selected
        )
    }
    
    private func makeIDs(
        _ banks: Bank?...
    ) -> Set<Bank.ID> {
        
        .init(banks.compactMap(\.?.id))
    }
}
