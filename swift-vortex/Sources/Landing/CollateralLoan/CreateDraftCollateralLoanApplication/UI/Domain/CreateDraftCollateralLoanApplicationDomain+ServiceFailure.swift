//
//  ServiceFailure.swift
//  
//
//  Created by Valentin Ozerov on 30.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public enum ServiceFailure: Error, Equatable {
        
        case connectivityError(String)
        case serverError(String)
    }
}

extension CreateDraftCollateralLoanApplicationDomain.ServiceFailure {
    
    public var message: String {
        
        switch self {
        case let .connectivityError(message):
            return message
            
        case let .serverError(message):
            return message
        }
    }
}
