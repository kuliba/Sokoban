//
//  CollateralLandingApplicationSaveConsentsPayload.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

public struct CollateralLandingApplicationSaveConsentsPayload: Equatable {
    
    public let applicationID: UInt
    public let verificationCode: String
    
    public init(applicationID: UInt, verificationCode: String) {
        
        self.applicationID = applicationID
        self.verificationCode = verificationCode
    }
}
