//
//  Form.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// A form that captures user consent and an optional OTP (one-time password).
/// It provides validation and determines the appropriate action based on its state.
public struct Form {
    
    /// The consent state required for form submission.
    public var consent: any ConsentProviding
    
    /// An optional OTP (one-time password) used for verification.
    public var otp: (any Validatable)?
    
    /// Initializes a form with consent and an optional OTP.
    ///
    /// - Parameters:
    ///   - consent: An object conforming to `ConsentProviding` representing the user's consent.
    ///   - otp: An optional object conforming to `Validatable` representing the OTP (if required).
    public init(
        consent: any ConsentProviding,
        otp: (any Validatable)? = nil
    ) {
        self.consent = consent
        self.otp = otp
    }
}

public extension Form {
    
    /// Represents the possible actions associated with the form.
    enum Action: Equatable {
        
        /// The action to continue without OTP verification.
        case `continue`
        
        /// The action to submit the form when OTP is provided.
        case submit
    }
    
    /// Determines the appropriate action based on whether an OTP is present.
    ///
    /// - Returns: `.continue` if OTP is `nil`, otherwise `.submit`.
    var action: Action { otp == nil ? .continue : .submit }
    
    /// Evaluates the form's validity based on consent and OTP status.
    ///
    /// - Returns: `true` if consent is granted and OTP (if present) is valid.
    var isValid: Bool { consent.isGranted && (otp?.isValid ?? true) }
}
