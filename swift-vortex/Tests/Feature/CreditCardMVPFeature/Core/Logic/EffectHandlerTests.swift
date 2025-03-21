//
//  EffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

final class EffectHandler<OTP> {
    
    private let otpWitness: OTPWitness
    
    init(otpWitness: @escaping OTPWitness) {
        
        self.otpWitness = otpWitness
    }
    
    typealias OTPWitness = (OTP) -> ((String) -> Void)?
}

extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .notifyOTP(otp, message):
            otpWitness(otp)?(message)
        }
    }
}

extension EffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CreditCardMVPCoreTests.Event
    typealias Effect = CreditCardMVPCoreTests.Effect<OTP>
}

import XCTest

final class EffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, otp) = makeSUT()
        
        XCTAssertEqual(otp.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - notifyOTP
    
    func test_shouldNotifyOTP_onNotifyOTP() {
        
        let message = anyMessage()
        let (sut, otp) = makeSUT()
        
        sut.handleEffect(.notifyOTP(otp, message)) { _ in }
        
        XCTAssertNoDiff(otp.payloads, [message])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = EffectHandler<OTP>
    private typealias OTP = CallSpy<String, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        otp: OTP
    ) {
        let otp = OTP(stubs: [()])
        let sut = SUT(otpWitness: { otp in otp.call })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(otp, file: file, line: line)
        
        return (sut, otp)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
