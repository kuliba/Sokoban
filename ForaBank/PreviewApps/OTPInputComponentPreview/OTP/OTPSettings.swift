//
//  OTPSettings.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent

enum OTPSettings: String, CaseIterable, Identifiable {
    
    case success, connectivity, server
    
    var id: Self { self }
}

extension OTPSettings {
    
    var result: OTPInputEffectHandler.SubmitOTPResult {
        
        switch self {
        case .success:
            return .success(())
        case .connectivity:
            return .failure(.connectivityError)
        case .server:
            return .failure(.serverError("Server Error Failure"))
        }
    }
}
