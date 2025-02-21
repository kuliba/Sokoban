//
//  CreateDraftCollateralLoanApplicationDomain.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

// Namespace
public enum CreateDraftCollateralLoanApplicationDomain {}

public extension CreateDraftCollateralLoanApplicationDomain {
    
    typealias CreateDraftApplicationCreatedResult<Confirmation, InformerPayload> = Swift.Result<
        DraftApplicationCreatedResult<Confirmation, InformerPayload>,
        BackendFailure<InformerPayload>
    >
    
    typealias CreateDraftApplicationResult<Confirmation, InformerPayload> = Swift.Result<
        CollateralLandingApplicationCreateDraftResult,
        BackendFailure<InformerPayload>
    >
    
    typealias SaveConsentsResult<InformerPayload> = Swift.Result<
        CollateralLandingApplicationSaveConsentsResult,
        BackendFailure<InformerPayload>
    >
}

public extension CreateDraftCollateralLoanApplicationDomain {
    
    struct DraftApplicationCreatedResult<Confirmation, InformerPayload> {
        
        let applicationResult: CreateDraftApplicationResult<Confirmation, InformerPayload>
        let confirmation: Confirmation
        
        public init(
            applicationResult: CreateDraftApplicationResult<Confirmation, InformerPayload>,
            confirmation: Confirmation
        ) {
            self.applicationResult = applicationResult
            self.confirmation = confirmation
        }
    }
}
