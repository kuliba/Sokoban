//
//  CollateralLandingApplicationCreateDraftResult.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

public struct CollateralLandingApplicationCreateDraftResult: Equatable {
    
    public let applicationId: UInt
    public let verificationCode: String

    public init(
        applicationId: UInt,
        verificationCode: String
    ) {
        self.applicationId = applicationId
        self.verificationCode = verificationCode
    }
}
