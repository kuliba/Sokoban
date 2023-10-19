//
//  CVVPinError.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

enum CVVPinError {
    
    enum CheckError: Error {
        
        case certificate
        case connectivity
    }
    
    struct ActivationError: Error {
        
        let message: String
    }
    
    struct OtpError: Error {
        
        let errorMessage: String
        let retryAttempts: Int
    }
    
    struct ChangePinError: Error {
        
        let errorMessage: String
        let retryAttempts: Int?
        let statusCode: Int
    }
    
    struct PinConfirmationError: Error {
        
        let errorMessage: String
        let statusCode: Int
    }

    enum ShowCVVError: Error {
        
        case check(CheckError)
        case activation(ActivationError)
        case otp(OtpError)
    }
}
