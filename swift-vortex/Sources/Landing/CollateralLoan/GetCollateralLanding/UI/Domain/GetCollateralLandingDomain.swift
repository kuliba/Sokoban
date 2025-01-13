//
//  GetCollateralLandingDomain.swift
//
//
//  Created by Valentin Ozerov on 13.01.2025.
//

// namespace
public enum GetCollateralLandingDomain {
    
    public struct LoadResultFailure: Equatable, Error {
        
        public init() {}
    }
    
    public typealias GetCollateralLanding = GetCollateralLandingProduct
    public typealias Result = Swift.Result<GetCollateralLanding, LoadResultFailure>
}
