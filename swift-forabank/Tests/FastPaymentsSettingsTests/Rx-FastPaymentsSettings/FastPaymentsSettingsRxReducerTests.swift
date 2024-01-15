//
//  FastPaymentsSettingsRxReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class FastPaymentsSettingsRxReducer {
    
}

extension FastPaymentsSettingsRxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        fatalError("unimplemented")
    }
}

extension FastPaymentsSettingsRxReducer {
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}


import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsRxReducerTests: XCTestCase {
    
    func test_() {
        
        _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
