//
//  GetCollateralLandingDocumentView.swift
//
//
//  Created by Valentin Ozerov on 13.12.2024.
//

import Combine
import SwiftUI

struct GetCollateralLandingDocumentView: View {
    
    let document: Document
    let config: Config.Documents.List
    let factory: Factory

    var body: some View {
        
        HStack(spacing: 0) {
            
            document.icon.map {
                
                factory.makeImageViewWithMD5Hash($0)
                    .frame(width: 20, height: 20)
                    .padding(.trailing, config.layouts.iconTrailingPadding)
            }
            
            if document.icon == nil {
                
                config.defaultIcon
                    .frame(width: 24, height: 24)
                    .padding(.trailing, config.layouts.iconTrailingPadding)
            }
            
            document.title.text(
                withConfig: .init(
                    textFont: config.fonts.title.font,
                    textColor: config.fonts.title.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension GetCollateralLandingDocumentView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Document = GetCollateralLandingProduct.Document
    typealias Factory = GetCollateralLandingFactory
}

// MARK: - Previews

struct GetCollateralLandingDocumentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingDocumentView(
            document: Product.carStub.documents.first!,
            config: Config.Documents.default.list,
            factory: .preview
        )
        .padding(.top, 300)
        .padding(.horizontal, 16)
    }

    typealias Factory = GetCollateralLandingFactory
    typealias Product = GetCollateralLandingProduct
    typealias Config = GetCollateralLandingConfig
}
