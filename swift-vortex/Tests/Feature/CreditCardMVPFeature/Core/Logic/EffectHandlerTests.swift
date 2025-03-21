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
    
    typealias ConfirmApplicationCompletion = (Event.ApplicationResult) -> Void
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
            confirmApplication(payload) { dispatch(.applicationResult($0)) }
            
        case .loadOTP:
            break
            
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
    
    func test_confirmApplication_shouldDeliverAlertFailure_onApplicationAlertFailure() {
        
        let (sut, confirmApplication, _) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeConfirmApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .alert)
        ) {
            confirmApplication.complete(with: .failure(.init(message: message, type: .alert)))
        }
    }
    
    func test_confirmApplication_shouldDeliverInformerFailure_onApplicationInformerFailure() {
        
        let (sut, confirmApplication, _) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeConfirmApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .informer)
        ) {
            confirmApplication.complete(with: .failure(.init(message: message, type: .informer)))
        }
    }
    
    func test_confirmApplication_shouldDeliverOTPFailure_onApplicationOTPFailure() {
        
        let (sut, confirmApplication, _) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeConfirmApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .otp)
        ) {
            confirmApplication.complete(with: .failure(.init(message: message, type: .otp)))
        }
    }
    
    func test_confirmApplication_shouldDeliverSuccess_onApplicationSuccess() {
        
        let (sut, confirmApplication, _) = makeSUT()
        let success = makeApplicationSuccess()
        
        expect(
            sut,
            with: makeConfirmApplication(),
            toDeliver: makeApplicationResultSuccess(success: success)
        ) {
            confirmApplication.complete(with: .success(success))
        }
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
    private typealias ConfirmApplication = Spy<ConfirmApplicationPayload, Event.ApplicationResult>
    private typealias OTP = CallSpy<String, Void>
    private typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
    
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
            otpWitness: { _ in otp.call }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(confirmApplication, file: file, line: line)
        trackForMemoryLeaks(otp, file: file, line: line)
        
        return (sut, confirmApplication, otp)
    }
    
    private func makeConfirmApplication(
        _ payload: ConfirmApplicationPayload? = nil
    ) -> Effect {
        
        return .confirmApplication(payload ?? makePayload())
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
