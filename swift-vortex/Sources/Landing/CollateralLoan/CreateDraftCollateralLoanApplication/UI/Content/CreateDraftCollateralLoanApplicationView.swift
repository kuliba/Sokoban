//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationView: View {
    
    let data: Data
    let config: Config
    let factory: Factory
    
    var body: some View {

        ScrollView {
            
            CreateDraftCollateralLoanApplicationHeaderView(
                data: data,
                config: config,
                factory: factory
            )
            
            Spacer()
        }
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationData
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            data: .preview,
            config: .preview,
            factory: Factory.preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
