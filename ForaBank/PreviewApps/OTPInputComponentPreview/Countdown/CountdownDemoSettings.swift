//
//  CountdownDemoSettings.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent

struct CountdownDemoSettings {
    
    var duration: Duration
    var initiateResult: InitiateResult
    
    enum Duration: Int, CaseIterable, Identifiable {
        
        case short = 10
        case sixty = 60
        
        var id: Self { self }
    }
    
    enum InitiateResult: String, CaseIterable, Identifiable {
        
        case success, connectivity, server
        
        var id: Self { self }
        
        var result: CountdownEffectHandler.InitiateOTPResult {
            
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
}
