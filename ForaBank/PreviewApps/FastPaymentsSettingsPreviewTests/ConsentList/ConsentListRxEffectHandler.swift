//
//  ConsentListRxEffectHandlerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ConsentListRxEffectHandler {
    
}

extension ConsentListRxEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension ConsentListRxEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

@testable import FastPaymentsSettingsPreview
import XCTest

final class ConsentListRxEffectHandlerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = ConsentListRxEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
