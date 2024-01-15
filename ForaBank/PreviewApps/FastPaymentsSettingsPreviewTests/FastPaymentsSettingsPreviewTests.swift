//
//  FastPaymentsSettingsPreviewTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

import FastPaymentsSettings
@testable import FastPaymentsSettingsPreview
import XCTest

final class FastPaymentsSettingsPreviewTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let spy = makeSUT().reducerSpy
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_openFastPaymentsSettings_should() throws {
        
        let (sut, spy) = makeSUT()
        
        sut.openFastPaymentsSettings()
        
        _ = try XCTUnwrap(sut.fpsViewModel)
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

// MARK: - DSL

private extension UserAccountViewModel {
    
    var fpsViewModel: FastPaymentsSettingsViewModel? {
        
        switch route.destination {
        case let .fastPaymentsSettings(fpsViewModel):
            return fpsViewModel
            
        default:
            return nil
        }
    }
}
