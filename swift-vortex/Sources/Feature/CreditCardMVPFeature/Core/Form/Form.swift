//
//  Form.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Represents a form with consent and optional OTP.
public struct Form {
    
    public var consent: any ConsentProviding
    public var otp: (any Validatable)?
    
    public init(
        consent: any ConsentProviding,
        otp: (any Validatable)? = nil
    ) {
        self.consent = consent
        self.otp = otp
    }
}

public extension Form {
    
    /// Calculates whether the form is valid based on consent and OTP.
    var isValid: Bool { consent.isGranted && (otp?.isValid ?? true) }
}
