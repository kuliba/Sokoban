//
//  OTPFieldIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

typealias OTPFieldViewModel = RxViewModel<OTPFieldState, OTPFieldEvent, OTPFieldEffect>

import OTPInputComponent
import RxViewModel
import XCTest

final class OTPFieldIntegrationTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = OTPFieldViewModel
    private typealias Reducer = OTPFieldReducer
    private typealias EffectHandler = OTPFieldEffectHandler

    private typealias SubmitOTPSpy = Spy<EffectHandler.SubmitOTPPayload, EffectHandler.SubmitOTPResult>

    private func makeSUT(
        initialState: OTPFieldState = .init(
            text: "",
            isInputComplete: false,
            status: nil
        ),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let reducer = Reducer()
        let submitOTPSpy = SubmitOTPSpy()
        let effectHandler = EffectHandler(
            submitOTP: submitOTPSpy.process(_:completion:)
        )
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
