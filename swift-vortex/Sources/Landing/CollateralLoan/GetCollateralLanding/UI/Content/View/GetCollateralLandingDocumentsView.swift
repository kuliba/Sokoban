//
//  GetCollateralLandingDocumentsView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import SwiftUI

struct GetCollateralLandingDocumentsView: View {

    let product: Product
    let config: Config
    let externalEvent: (ExternalEvent) -> Void
    let factory: Factory
    
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
                    
                    GetCollateralLandingDocumentView(
                        document: $0,
                        config: config.list,
                        externalEvent: externalEvent,
                        factory: factory
                    )
                }
                .padding(.horizontal, config.list.layouts.horizontalPadding)
                .padding(.bottom, config.list.layouts.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, config.list.layouts.topPadding)
            .padding(.bottom, config.list.layouts.bottomPadding)
        }
    }    
}

extension GetCollateralLandingDocumentsView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias Factory = GetCollateralLandingFactory
    typealias State = GetCollateralLandingDomain.State
    typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent
}

// MARK: - Previews

struct GetCollateralLandingDocumentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingDocumentsView(
            product: .carStub,
            config: .default,
            externalEvent: { print($0) },
            factory: .preview
        )
    }
    
    static let carStub = GetCollateralLandingProduct.carStub
    static let realEstateData = GetCollateralLandingProduct.realEstateStub
    typealias Factory = GetCollateralLandingFactory
}
