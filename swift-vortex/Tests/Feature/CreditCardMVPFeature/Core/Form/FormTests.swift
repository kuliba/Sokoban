//
//  FormTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

import CreditCardMVPCore
import XCTest

final class FormTests: XCTestCase {
    
    // MARK: - action
    
    func test_action_shouldBeContinue_onNilOTP() {
        
        XCTAssertNoDiff(makeForm(otp: nil).action, .continue)
    }
    
    func test_action_shouldBeSubmit_onNonNilOTP() {
        
        XCTAssertNoDiff(makeForm(otp: makeOTP()).action, .submit)
    }
    
    // MARK: - isValid
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andNilOTP() {
        
        XCTAssertFalse(isValid(isGranted: false, isValid: nil))
    }
    
    func test_isValid_shouldBeTrue_onConsentGranted_andNilOTP() {
        
        XCTAssertTrue(isValid(isGranted: true, isValid: nil))
    }
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andValidOTP() {
        
        XCTAssertFalse(isValid(isGranted: false, isValid: true))
    }
    
    func test_isValid_shouldBeFalse_onConsentGranted_andInvalidOTP() {
        
        XCTAssertFalse(isValid(isGranted: true, isValid: false))
    }
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andInvalidOTP() {
        
        XCTAssertFalse(isValid(isGranted: false, isValid: false))
    }
    
    func test_isValid_shouldBeTrue_onConsentGranted_andValidOTP() {
        
        XCTAssertTrue(isValid(isGranted: true, isValid: true))
    }
    
    // MARK: - Helpers
    
    private func isValid(
        isGranted: Bool,
        isValid: Bool?
    ) -> Bool {
        
        let form = makeForm(
            consent: makeConsent(isGranted: isGranted),
            otp: isValid.map { makeOTP(isValid: $0) }
        )
        
        return form.isValid
    }
    
    private func makeForm(
        consent: Consent? = nil,
        otp: OTP?
    ) -> Form {
        
        return .init(
            consent: consent ?? makeConsent(),
            otp: otp
        )
    }
    
    private struct Consent: ConsentProviding {
        
        let isGranted: Bool
    }
    
    private func makeConsent(
        isGranted: Bool = .random()
    ) -> Consent {
        
        return .init(isGranted: isGranted)
    }
    
    private struct OTP: Validatable {
        
        let isValid: Bool
    }
    
    private func makeOTP(
        isValid: Bool = .random()
    ) -> OTP {
        
        return .init(isValid: isValid)
    }
}
