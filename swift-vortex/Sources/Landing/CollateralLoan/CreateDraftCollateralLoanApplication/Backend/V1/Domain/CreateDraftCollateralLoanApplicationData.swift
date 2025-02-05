//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 27.11.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateDraftCollateralLoanApplicationData: Equatable {
        
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
}
