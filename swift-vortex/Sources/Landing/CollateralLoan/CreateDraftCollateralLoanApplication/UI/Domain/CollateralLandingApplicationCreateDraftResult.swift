//
//  CollateralLandingApplicationCreateDraftResult.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

public struct CollateralLandingApplicationCreateDraftResult: Equatable {
    
    public let applicationID: UInt

    public init(
        applicationID: UInt
    ) {
        self.applicationID = applicationID
    }
}
