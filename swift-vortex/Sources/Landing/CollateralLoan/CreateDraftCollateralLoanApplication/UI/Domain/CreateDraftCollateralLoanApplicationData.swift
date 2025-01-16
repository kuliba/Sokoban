//
//  CreateDraftCollateralLoanApplicationData.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

struct CreateDraftCollateralLoanApplicationData {
    
    let name: String
    let icons: Icons
    
    struct Icons {
        
        let productName: String
    }
}

extension CreateDraftCollateralLoanApplicationData {
    
    static let preview = Self(
        name: "Кредит под залог транспорта",
        icons: .init(
            productName: "info"
        )
    )
}
