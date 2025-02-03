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
    let makeImageViewWithMD5Hash: Factory.makeImageViewWithMD5Hash

    var body: some View {
        
        HStack(spacing: 0) {
            
            document.icon.map {
                makeImageViewWithMD5Hash($0)
                    .frame(width: 20, height: 20)
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
            makeImageViewWithMD5Hash: Factory.preview.makeImageViewWithMD5Hash
        )
        .padding(.top, 300)
        .padding(.horizontal, 16)
    }

    typealias Factory = GetCollateralLandingFactory
    typealias Product = GetCollateralLandingProduct
    typealias Config = GetCollateralLandingConfig
}
