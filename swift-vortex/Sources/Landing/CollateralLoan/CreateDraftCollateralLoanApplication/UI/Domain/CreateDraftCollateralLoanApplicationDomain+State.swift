//
//  CreateDraftCollateralLoanApplicationDomain+State.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct State: Equatable {
        
        public let data: CreateDraftCollateralLoanApplicationUIData
        
        public init(data: CreateDraftCollateralLoanApplicationUIData) {
         
            self.data = data
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    public static let preview = Self(
        data: .preview
    )
}
