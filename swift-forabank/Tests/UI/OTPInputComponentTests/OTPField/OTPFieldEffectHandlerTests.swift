//
//  OTPFieldEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent
import RxViewModel
import XCTest

extension OTPFieldEffectHandler: EffectHandler {}

final class OTPFieldEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - submitOTP
    
    func test_submitOTP_shouldPassPayload() {
        
        let otp = UUID().uuidString
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.submitOTP(otp)) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [.init(otp)])
    }
    
    func test_submitOTP_shouldDeliverSuccessOnSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: submitOTP(), toDeliver: .otpValidated, on: {
            
            spy.complete(with: .success(()))
        })
    }
    
    func test_submitOTP_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: submitOTP(), toDeliver: connectivityError(), on: {
            
            spy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_submitOTP_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: submitOTP(), toDeliver: serverError(message), on: {
            
            spy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OTPFieldEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias SubmitOTPSpy = Spy<SUT.SubmitOTPPayload, SUT.SubmitOTPResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: SubmitOTPSpy
    ) {
        let spy = SubmitOTPSpy()
        let sut = SUT(submitOTP: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyOTP(
        _ otp: String = UUID().uuidString
    ) -> String {
        
        return otp
    }
    
    private func submitOTP(
        _ otp: String? = nil
    ) -> Effect {
        
        .submitOTP(anyOTP())
    }
    
    private func connectivityError(
    ) -> Event {
        
        .failure(.connectivityError)
    }
    
    private func serverError(
        _ message: String = anyMessage()
    ) -> Event {
        
        .failure(.serverError(message))
    }
}
