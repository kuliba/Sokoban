//
//  CollateralLandingApplicationCreateDraftResult.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

public struct CollateralLandingApplicationCreateDraftResult: Equatable {
    
    public let applicationId: UInt
    
    public init(applicationId: UInt) {
     
        self.applicationId = applicationId
    }
}
