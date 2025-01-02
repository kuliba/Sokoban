//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationView: View {
    
    let factory: Factory
    let config: Config
    let data: Data
    
    var body: some View {

        ScrollView {
            
            CreateDraftCollateralLoanApplicationHeaderView(
                config: config,
                data: data,
                makeImageView: factory.makeImageView
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
            factory: Factory.preview,
            config: .default,
            data: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
