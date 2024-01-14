//
//  ConsentListRxReducerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ConsentListRxReducer {
    
}

extension ConsentListRxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        fatalError()
    }
}

extension ConsentListRxReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

@testable import FastPaymentsSettingsPreview
import XCTest

final class ConsentListRxReducerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = ConsentListRxReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
