//
//  OTPInputEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent
import RxViewModel
import XCTest

extension OTPInputEffectHandler: EffectHandler {}

final class OTPInputEffectHandlerTests: XCTestCase {
    
    // MARK: - CountdownEffect
    
    func test_countdownEffect_shouldDeliverHandleCountdownEffectResult() {
        
        let (sut, countdownSpy, _) = makeSUT()
        
        expect(sut, with: .countdown(.initiate), toDeliver: .countdown(.prepare), on: {
            
            countdownSpy.complete(with: .prepare)
        })
    }
    
    // MARK: - OTPFieldEffect
    
    func test_otpFieldEffect_shouldDeliverHandleOTPFieldEffectResult() {
        
        let (sut, _, otpFieldSpy) = makeSUT()
        
        expect(sut, with: .otpField(.submitOTP(anyMessage())), toDeliver: .otpField(.confirmOTP), on: {
            
            otpFieldSpy.complete(with: .confirmOTP)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias CountdownEffectHandlerSpy = EffectHandlerSpy<CountdownEvent, CountdownEffect>
    private typealias OTPFieldEffectHandlerSpy = EffectHandlerSpy<OTPFieldEvent, OTPFieldEffect>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        countdownSpy: CountdownEffectHandlerSpy,
        otpFieldSpy: OTPFieldEffectHandlerSpy
    ) {
        
        let countdownEffectHandlerSpy = CountdownEffectHandlerSpy()
        let otpFieldEffectHandlerSpy = OTPFieldEffectHandlerSpy()
        
        let sut = SUT(
            handleCountdownEffect: countdownEffectHandlerSpy.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandlerSpy.handleEffect(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(countdownEffectHandlerSpy, file: file, line: line)
        trackForMemoryLeaks(otpFieldEffectHandlerSpy, file: file, line: line)
        
        return (sut, countdownEffectHandlerSpy, otpFieldEffectHandlerSpy)
    }
}
