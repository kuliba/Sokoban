//
//  EffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

/// A type that provides a verification code (e.g., OTP).
public protocol VerificationCodeProviding {
    
    /// The verification code as a string (e.g., OTP).
    var verificationCode: String { get }
}

final class EffectHandler<ApplicationSuccess, ConfirmApplicationPayload, OTP>
where ConfirmApplicationPayload: VerificationCodeProviding {
    
    private let confirmApplication: ConfirmApplication
    private let otpWitness: OTPWitness
    
    init(
        confirmApplication: @escaping ConfirmApplication,
        otpWitness: @escaping OTPWitness
    ) {
        self.confirmApplication = confirmApplication
        self.otpWitness = otpWitness
    }
    
    typealias ConfirmApplicationCompletion = (Void) -> Void
    typealias ConfirmApplication = (ConfirmApplicationPayload, @escaping ConfirmApplicationCompletion) -> Void
    
    typealias OTPWitness = (OTP) -> (String) -> Void
}

extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .confirmApplication(payload):
            confirmApplication(payload) { }
            
        case let .notifyOTP(otp, message):
            otpWitness(otp)(message)
        }
    }
}

extension EffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CreditCardMVPCoreTests.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
}

import XCTest

final class EffectHandlerTests: LogicTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, confirmApplication, otp) = makeSUT()
        
        XCTAssertEqual(confirmApplication.callCount, 0)
        XCTAssertEqual(otp.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - confirmApplication
    
    func test_confirmApplication_shouldCallConfirmApplicationWithPayload() {
        
        let payload = makePayload()
        let (sut, confirmApplication, _) = makeSUT()
        
        sut.handleEffect(.confirmApplication(payload)) { _ in }
        
        XCTAssertNoDiff(confirmApplication.payloads, [payload])
    }
    
    // MARK: - notifyOTP
    
    func test_notifyOTP_shouldCallNotifyOTP() {
        
        let message = anyMessage()
        let (sut, _, otp) = makeSUT()
        
        sut.handleEffect(.notifyOTP(otp, message)) { _ in }
        
        XCTAssertNoDiff(otp.payloads, [message])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = EffectHandler<ApplicationSuccess, ConfirmApplicationPayload, OTP>
    private typealias ConfirmApplication = Spy<ConfirmApplicationPayload, Void>
    private typealias OTP = CallSpy<String, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        confirmApplication: ConfirmApplication,
        otp: OTP
    ) {
        let confirmApplication = ConfirmApplication()
        let otp = OTP(stubs: [()])
        let sut = SUT(
            confirmApplication: confirmApplication.process,
            otpWitness: { otp in otp.call }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(confirmApplication, file: file, line: line)
        trackForMemoryLeaks(otp, file: file, line: line)
        
        return (sut, confirmApplication, otp)
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
