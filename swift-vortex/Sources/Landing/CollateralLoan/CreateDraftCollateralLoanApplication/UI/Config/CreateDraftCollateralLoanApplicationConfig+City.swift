//
//  CreateDraftCollateralLoanApplicationConfig+City.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct City {
        
        public let title: String
        
        public init(title: String) {
            
            self.title = title
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.City {
    
    static let preview = Self(title: "Город получения кредита")
}
