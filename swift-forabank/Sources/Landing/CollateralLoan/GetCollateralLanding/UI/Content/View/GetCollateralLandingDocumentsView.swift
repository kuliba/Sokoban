//
//  GetCollateralLandingDocumentsView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import SwiftUI

struct GetCollateralLandingDocumentsView: View {

    let config: Config
    let product: Product
    
    var body: some View {
        
        documentsView
            .padding(.top, config.paddings.outerTop)
    }
    
    private var documentsView: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(config.documents.background)
                .frame(maxWidth: .infinity)
            
            documentsListView(config.documents)
        }
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
    }
    
    private func documentsListView(_ config: Config.Documents) -> some View {
                
        VStack {
        
            config.header.text.text(
                withConfig: .init(
                    textFont: config.header.headerFont.font,
                    textColor: config.header.headerFont.foreground
                )
            )
            .padding(.horizontal, config.list.layouts.horizontalPadding)
            .padding(.top, config.topPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                
                ForEach(product.documents, id: \.title) {
                    
                    documentView($0, config: config)
                }
                .padding(.horizontal, config.list.layouts.horizontalPadding)
                .padding(.bottom, config.list.layouts.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, config.list.layouts.topPadding)
            .padding(.bottom, config.list.layouts.bottomPadding)
        }
    }
    
    private func documentView(_ document: Document, config: Config.Documents) -> some View {
        
        HStack(spacing: 0) {
            
            Image(systemName: "document")
                .padding(.trailing, config.list.layouts.iconTrailingPadding)
            
            document.title.text(
                withConfig: .init(
                    textFont: config.list.fonts.title.font,
                    textColor: config.list.fonts.title.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension GetCollateralLandingDocumentsView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Document = GetCollateralLandingProduct.Document
    typealias Product = GetCollateralLandingProduct
}

// MARK: - Previews

struct GetCollateralLandingDocumentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingDocumentsView(
            config: .default,
            product: carStub
        )
    }
    
    static let carStub = GetCollateralLandingProduct.carStub
    static let realEstateData = GetCollateralLandingProduct.realEstateStub
}
