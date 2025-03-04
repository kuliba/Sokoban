//
//  GetCollateralLandingDomain.swift
//
//
//  Created by Valentin Ozerov on 13.01.2025.
//

public enum GetCollateralLandingDomain {
    
    public typealias GetCollateralLanding = GetCollateralLandingProduct
    public typealias Result<InformerPayload> = Swift.Result<GetCollateralLanding, BackendFailure<InformerPayload>>
}
