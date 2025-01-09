//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationView: View {
    
    let factory: Factory
    
    var body: some View {
        
        Text("CreateDraftCollateralLoanApplicationView")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            factory: Factory.preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
