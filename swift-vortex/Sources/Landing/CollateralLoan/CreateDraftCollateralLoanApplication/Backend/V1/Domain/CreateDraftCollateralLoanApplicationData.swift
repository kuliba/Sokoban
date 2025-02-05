//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 27.11.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateDraftCollateralLoanApplicationData: Equatable {
        
        public let applicationID: UInt

        public init(
            applicationID: UInt
        ) {
            self.applicationID = applicationID
        }
    }
}
