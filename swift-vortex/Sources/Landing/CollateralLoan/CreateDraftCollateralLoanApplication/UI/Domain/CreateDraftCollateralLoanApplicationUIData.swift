//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Foundation

public struct CreateDraftCollateralLoanApplicationUIData {
    
    let name: String
    let icons: Icons
    
    public init(name: String, icons: Icons) {
        
        self.name = name
        self.icons = icons
    }
    
    public struct Icons {
        
        let productName: String
        
        public init(
            productName: String
        ) {
            self.productName = productName
        }
    }
}

extension CreateDraftCollateralLoanApplicationUIData {
    
    static let preview = Self(
        name: "Кредит под залог транспорта",
        icons: .init(
            productName: "info"
        )
    )
}

extension CreateDraftCollateralLoanApplicationUIData: Equatable {}
extension CreateDraftCollateralLoanApplicationUIData.Icons: Equatable {}

extension CreateDraftCollateralLoanApplicationUIData: Identifiable {
    
    public var id: String { name }
}
