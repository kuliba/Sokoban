//
//  CreateDraftCollateralLoanApplicationConfig+Period.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Period {
        
        public let title: String
        
        public init(title: String) {
            
            self.title = title
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Period {
    
    static let preview = Self(title: "Срок кредита")
}
