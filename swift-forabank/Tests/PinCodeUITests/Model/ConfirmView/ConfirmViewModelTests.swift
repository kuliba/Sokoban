//
//  ConfirmViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 25.07.2023.
//

@testable import PinCodeUI

import XCTest

final class ConfirmViewModelTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            maxDigits: 4,
            handler: { _, _ in }
        )
        
        XCTAssertEqual(sut.maxDigits, 4)
        XCTAssertFalse(sut.isDisabled)
        XCTAssertNotNil(sut.handler)
    }
    
    //MARK: - test submint
    
    func test_submint_pinEmpty_isDisableFalse() {
        
        let sut = makeSUT()
        
        sut.otp = ""
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        
        XCTAssertFalse(sut.isDisabled)
    }

    func test_submint_pinLessMaxDigits_isDisableFalse() {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.otp = "1234"
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        
        XCTAssertFalse(sut.isDisabled)
    }

    func test_submint_pinEqualMaxDigits_isDisableTrue() {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.otp = "123456"
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        
        XCTAssertTrue(sut.isDisabled)
    }

    func test_submint_pinOverMaxDigits_pinCutToMaxDigitsIsDisableTrue() async {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.otp = "1234567"
        
        XCTAssertEqual(sut.otp, "1234567")

        sut.submitOtp()
        
        XCTAssertEqual(sut.otp, "123456")
    }
    
    func test_submint_errorCode_shouldSetOtpEmptyIsDisableFalse() {
        
        let sut = makeSUT(maxDigits: 6) { _, completionHandler in
            
            completionHandler(.cvvError(.errorForAlert(.init("error"))))
        }
        
        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.otp, "")
        XCTAssertFalse(sut.isDisabled)
    }
    
    func test_submint_noRetry_shouldSetOtpEmptyIsDisableFalse() {
        
        let sut = makeSUT(maxDigits: 6) { _, completionHandler in
            
            completionHandler(.cvvError(.noRetry(.init("error"), .init("ok"))))
        }
        
        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.otp, "")
        XCTAssertFalse(sut.isDisabled)
    }
    
    func test_submint_correctCode_shouldSetIsDisableTrue() async {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertTrue(sut.isDisabled)
    }
    
    func test_changePin_error_shouldSetOtpEmptyIsDisableFalse() {
        
        let sut = makeSUT(actionType: .changePin("1222"), handler: {_,_ in }) {_, completionHandler in
                
                completionHandler(.pinError(.errorForAlert(.init("error"))))
        }

        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.otp, "")
        XCTAssertFalse(sut.isDisabled)
    }
    
    func test_changePin_weakPin_shouldSetOtpEmptyIsDisableFalse() {
        
        let sut = makeSUT(actionType: .changePin("1222"), handler: {_,_ in }) {_, completionHandler in
                
            completionHandler(.pinError(.weakPinAlert(.init("error"), .init("ok"))))
        }

        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.otp, "")
        XCTAssertFalse(sut.isDisabled)
    }

    func test_changePin_errorScreen_shouldSetOtpEmptyIsDisableFalse() {
        
        let sut = makeSUT(actionType: .changePin("1222"), handler: {_,_ in }) {_, completionHandler in
                
                completionHandler(.pinError(.errorScreen))
        }

        sut.otp = "123456"
        
        XCTAssertEqual(sut.otp, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitOtp()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.otp, "")
        XCTAssertFalse(sut.isDisabled)
    }
    
    //MARK: - test getDigit
    
    func test_getDigit_indexOverPinLength_returnNil() {
        
        let sut = makeSUT(otp: "123")
                
        let digit = sut.getDigit(at: 4)
                
        XCTAssertNil(digit)
    }
    
    func test_getDigit_indexLessPinLength_returnStringDigit() {
        
        let sut = makeSUT(otp: "123")
                
        let digit = sut.getDigit(at: 1)
                
        XCTAssertEqual(digit, "2")
    }

    //MARK: - Helpers

    private func makeSUT(
        phoneNumber: PhoneDomain.Phone = "+1..99",
        cardId: CardDomain.CardId = 111,
        actionType: ConfirmViewModel.CVVPinAction = .showCvv,
        otp: OtpDomain.Otp = "",
        maxDigits: Int = 6,
        handler: @escaping (OtpDomain.Otp, (ErrorDomain?) -> Void) -> Void = { _, _ in },
        handlerChangePin: ConfirmViewModel.ChangePinHandler? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfirmViewModel {
        
        let sut: ConfirmViewModel = .init(
            phoneNumber: phoneNumber,
            cardId: cardId, 
            actionType: actionType,
            maxDigits: maxDigits,
            otp: otp,
            handler: handler,
            handlerChangePin: handlerChangePin,
            showSpinner: {},
            resendRequestAfterClose: { _,_  in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
            
        return (sut)
    }
}
