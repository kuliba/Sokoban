//
//  CollateralLandingApplicationSaveConsentsPayload.swift
//
//
//  Created by Valentin Ozerov on 21.01.2025.
//

public struct CollateralLandingApplicationSaveConsentsPayload: Equatable {
    
    public let applicationId: UInt
    public let verificationCode: String
    
    public init(applicationId: UInt, verificationCode: String) {
        
        self.applicationId = applicationId
        self.verificationCode = verificationCode
    }
}
