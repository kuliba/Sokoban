//
//  CollateralLandingApplicationSaveConsentsPayload.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

public struct CollateralLandingApplicationSaveConsentsPayload: Equatable {
    
    public let applicationID: UInt
    public let verificationCode: String
    public let icons: CollateralLandingApplicationSaveConsentsResult.Icons
    
    public init(
        applicationID: UInt,
        verificationCode: String,
        icons: CollateralLandingApplicationSaveConsentsResult.Icons
    ) {
        self.applicationID = applicationID
        self.verificationCode = verificationCode
        self.icons = icons
    }
}
