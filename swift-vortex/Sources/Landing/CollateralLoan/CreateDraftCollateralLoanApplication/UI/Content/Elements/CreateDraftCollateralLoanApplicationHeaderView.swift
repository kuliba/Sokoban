//
//  CreateDraftCollateralLoanApplicationHeaderView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationHeaderView: View {
    
    let data: Data
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: config.layouts.cornerRadius)
                .fill(config.colors.background)
                .frame(maxWidth: .infinity)
            
            InfoView(
                info: .init(
                    id: .other(UUID().uuidString),
                    title: config.header.title,
                    value: data.name,
                    style: .expanded
                ),
                config: .init(title: config.fonts.title, value: config.fonts.value),
                icon: factory.makeImageView
            )
            .padding(config.layouts.paddings.contentStack)
        }
        .padding(config.layouts.paddings.stack)
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension CreateDraftCollateralLoanApplicationHeaderView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationData
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationHeaderView(
            data: .preview,
            config: .preview,
            factory: Factory.preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationData
}
