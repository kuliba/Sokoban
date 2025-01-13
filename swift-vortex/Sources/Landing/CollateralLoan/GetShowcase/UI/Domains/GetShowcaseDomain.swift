//
//  GetShowcaseDomain.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

public enum GetShowcaseDomain {

    public struct LoadResultFailure: Equatable, Error {
        
        public init() {}
    }
    
    public typealias ShowCase = CollateralLoanLandingGetShowcaseData
    public typealias Result = Swift.Result<ShowCase, LoadResultFailure>
}
