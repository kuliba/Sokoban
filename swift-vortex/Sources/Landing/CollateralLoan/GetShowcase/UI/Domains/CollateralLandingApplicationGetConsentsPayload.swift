//
//  CollateralLandingApplicationGetConsentsPayload.swift
//  
//
//  Created by Valentin Ozerov on 11.02.2025.
//

public struct CollateralLandingApplicationGetConsentsPayload: Equatable {
    
    public let cryptoVersion: String
    public let verificationCode: String
    public let applicationID: UInt

    public init(
        cryptoVersion: String = "1.0", // Constant
        verificationCode: String,
        applicationID: UInt
    ) {
        self.cryptoVersion = cryptoVersion
        self.verificationCode = verificationCode
        self.applicationID = applicationID
    }
}
