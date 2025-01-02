//
//  CreateDraftCollateralLoanApplicationHeaderView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationHeaderView: View {
    
    let config: Config
    let data: Data
    let makeImageView: Factory.MakeImageView
    
    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: config.layouts.cornerRadius)
                .fill(config.colors.background)
                .frame(maxWidth: .infinity)

            content
        }
        .padding(.leading, config.layouts.paddings.leading)
        .padding(.trailing, config.layouts.paddings.trailing)
        .padding(.vertical, config.layouts.paddings.vertical)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var content: some View {
        
        HStack(spacing: config.layouts.contentHorizontalSpacing) {
            
            iconView
            infoView
        }
        .padding(.leading, config.layouts.paddings.contentLeading)
        .padding(.trailing, config.layouts.paddings.contentTrailing)
        .padding(.vertical, config.layouts.paddings.contentVertical)
    }
    
    private var iconView: some View {
        
        makeImageView(data.icons.productName)
            .frame(
                width: config.layouts.iconSize.width,
                height: config.layouts.iconSize.height
            )
    }
    
    private var infoView: some View {
        
        VStack(spacing: config.layouts.contentVerticalSpacing) {
            
            config.header.title.text(
                withConfig: .init(
                    textFont: config.fonts.title.font,
                    textColor: config.fonts.title.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            
            data.name.text(
                withConfig: .init(
                    textFont: config.fonts.message.font,
                    textColor: config.fonts.message.foreground
                )
            )
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
            config: .default,
            data: .preview,
            makeImageView: Factory.preview.makeImageView
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationData
}
