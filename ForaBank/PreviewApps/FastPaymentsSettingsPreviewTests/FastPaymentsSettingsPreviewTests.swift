//
//  FastPaymentsSettingsPreviewTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

@testable import FastPaymentsSettingsPreview
import XCTest

final class FastPaymentsSettingsPreviewTests: XCTestCase {
    
    func test_init() {
        
        _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UserAccountViewModel
    private typealias _ReducerSpy = ReducerSpy<FastPaymentsSettingsState?, FastPaymentsSettingsEvent>
    
    private func makeSUT(
        initialState: FastPaymentsSettingsState? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        reducerSpy: _ReducerSpy
    ) {
        let reducerSpy = _ReducerSpy()
        let sut = SUT(
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    FastPaymentsSettingsViewModel(
                        initialState: initialState,
                        reduce: reducerSpy.reduce(_:_:_:)
                    )
                }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducerSpy, file: file, line: line)
        
        return (sut, reducerSpy)
    }
}
