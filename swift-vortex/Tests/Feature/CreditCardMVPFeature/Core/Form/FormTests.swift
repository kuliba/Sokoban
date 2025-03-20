//
//  FormTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

protocol ConsentProviding {
    
    var isGranted: Bool { get }
}

protocol Validatable {
    
    var isValid: Bool { get }
}

struct Form {
    
    var consent: any ConsentProviding
    var otp: (any Validatable)?
}

extension Form {
    
    var isValid: Bool { consent.isGranted && (otp?.isValid ?? true) }
}

import XCTest

final class FormTests: XCTestCase {
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andNilOTP() {
        
        XCTAssertFalse(makeForm(consent: makeConsent(isGranted: false), otp: nil).isValid)
    }
    
    func test_isValid_shouldBeTrue_onConsentGranted_andNilOTP() {
        
        XCTAssertTrue(makeForm(consent: makeConsent(isGranted: true), otp: nil).isValid)
    }
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andValidOTP() {
        
        XCTAssertFalse(makeForm(consent: makeConsent(isGranted: false), otp: makeOTP(isValid: true)).isValid)
    }
    
    func test_isValid_shouldBeFalse_onConsentGranted_andInvalidOTP() {
        
        XCTAssertFalse(makeForm(consent: makeConsent(isGranted: true), otp: makeOTP(isValid: false)).isValid)
    }
    
    func test_isValid_shouldBeFalse_onConsentNotGranted_andInvalidOTP() {
        
        XCTAssertFalse(makeForm(consent: makeConsent(isGranted: false), otp: makeOTP(isValid: false)).isValid)
    }
    
    func test_isValid_shouldBeTrue_onConsentGranted_andValidOTP() {
        
        XCTAssertTrue(makeForm(consent: makeConsent(isGranted: true), otp: makeOTP(isValid: true)).isValid)
    }
    
    // MARK: - Helpers
    
    private func makeForm(
        consent: Consent,
        otp: OTP?
    ) -> Form {
        
        return .init(consent: consent, otp: otp)
    }
    
    private struct Consent: ConsentProviding {
        
        let isGranted: Bool
    }
    
    private func makeConsent(
        isGranted: Bool = false
    ) -> Consent {
        
        return .init(isGranted: isGranted)
    }
    
    private struct OTP: Validatable {
        
        let isValid: Bool
    }
    
    private func makeOTP(
        isValid: Bool = false
    ) -> OTP {
        
        return .init(isValid: isValid)
    }
}
