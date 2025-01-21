//
//  CreateDraftCollateralLoanApplicationDomain.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

public enum CreateDraftCollateralLoanApplicationDomain {

    public struct LoadResultFailure: Equatable, Error {
        
        public init() {}
    }
    
    public typealias CreateDraftApplicationResult = Swift.Result<
        CollateralLandingApplicationCreateDraftResult,
        LoadResultFailure
    >
    
    public typealias SaveConsentsResult = Swift.Result<
        CollateralLandingApplicationSaveConsentsResult, LoadResultFailure
    >

}
