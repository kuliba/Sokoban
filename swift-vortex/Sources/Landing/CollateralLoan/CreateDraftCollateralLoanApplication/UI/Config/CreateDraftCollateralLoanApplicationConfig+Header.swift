//
//  CreateDraftCollateralLoanApplicationConfig+Header.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Header {
        
        public let title: String
        
        public init(title: String) {
            
            self.title = title
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Header {
    
    static let preview = Self(title: "Наименование кредита")
}
