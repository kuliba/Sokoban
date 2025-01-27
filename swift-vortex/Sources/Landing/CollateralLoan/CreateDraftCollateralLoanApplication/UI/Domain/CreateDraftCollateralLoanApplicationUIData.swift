//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Foundation

public struct CreateDraftCollateralLoanApplicationUIData {
    
    public let name: String
    public let icons: Icons
    
    public init(name: String, icons: Icons) {
        
        self.name = name
        self.icons = icons
    }
    
    public struct Icons {
        
        public let productName: String
        public let amount: String
        
        public init(
            productName: String,
            amount: String
        ) {
            self.productName = productName
            self.amount = amount
        }
    }
}

extension CreateDraftCollateralLoanApplicationUIData {
    
    static let preview = Self(
        name: "Кредит под залог транспорта",
        icons: .init(
            productName: "info",
            amount: "info"
        )
    )
}

extension CreateDraftCollateralLoanApplicationUIData: Equatable {}
extension CreateDraftCollateralLoanApplicationUIData.Icons: Equatable {}

extension CreateDraftCollateralLoanApplicationUIData: Identifiable {
    
    public var id: String { name }
}
