//
//  CreateDraftCollateralLoanApplicationConfig+Percent.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Percent {
        
        public let title: String
        
        public init(title: String) {
            
            self.title = title
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Percent {
    
    static let preview = Self(title: "Процентная ставка")
}
