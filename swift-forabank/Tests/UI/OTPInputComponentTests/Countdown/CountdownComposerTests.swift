//
//  CountdownComposerTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import XCTest

final class CountdownComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CountdownComposer
    private typealias ActivateSpy = Spy<Void, SUT.ActivateResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        activateSpy: ActivateSpy
    ) {
        let activateSpy = ActivateSpy()
        let sut = SUT(activate: activateSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(activateSpy, file: file, line: line)
        
        return (sut, activateSpy)
    }
}
