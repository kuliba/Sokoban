//
//  OTPInputIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent
typealias OTPInputViewModel = RxViewModel<OTPInputState, OTPInputEvent, OTPInputEffect>

import OTPInputComponent
import RxViewModel
import XCTest

final class OTPInputIntegrationTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputViewModel
    private typealias Reducer = OTPInputReducer
    private typealias EffectHandler = OTPInputEffectHandler
    
    private func makeSUT(
        initialState: OTPInputState = .init(text: "", isOTPComplete: false),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let reducer = Reducer()
        let effectHandler = EffectHandler()
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
