//
//  CreateDraftCollateralLoanApplicationDomain+Effect.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public enum Effect: Equatable {
        
        case createDraftApplication(CreateDraftPayload)
        case saveConsents(SaveConsentsPayload)
        case showSaveConsentsResult(SaveConsentsResult)
    }
    
    public typealias CreateDraftPayload = CollateralLandingApplicationCreateDraftPayload
    public typealias SaveConsentsPayload = CollateralLandingApplicationSaveConsentsPayload
}
