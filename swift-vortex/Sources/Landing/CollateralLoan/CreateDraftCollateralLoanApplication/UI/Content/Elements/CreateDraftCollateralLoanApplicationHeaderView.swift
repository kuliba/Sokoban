//
//  CreateDraftCollateralLoanApplicationHeaderView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationHeaderView: View {
    
    let data: Data
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: config.layouts.cornerRadius)
                .fill(config.colors.background)
                .frame(maxWidth: .infinity)
            
            content
        }
        .padding(config.layouts.paddings.stack)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var content: some View {
        
        HStack(spacing: config.layouts.contentHorizontalSpacing) {
            
            iconView
            infoView
        }
        .padding(config.layouts.paddings.contentStack)
    }
    
    private var iconView: some View {
        
        factory.makeImageView(data.icons.productName)
            .frame(config.layouts.iconSize)
    }
    
    private var infoView: some View {
        
        VStack(spacing: config.layouts.contentVerticalSpacing) {
            
            config.header.title.text(withConfig: config.fonts.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            data.name.text(withConfig: config.fonts.message)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
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
