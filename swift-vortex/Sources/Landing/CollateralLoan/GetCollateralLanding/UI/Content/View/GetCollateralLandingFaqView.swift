//
//  GetCollateralLandingFaqView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import SwiftUI
import DropDownTextListComponent

struct GetCollateralLandingFaqView: View {
    
    let product: Product
    let config: Config

    var body: some View {
        
        DropDownTextListView(
            config: config.faq,
            list: product.dropDownTextList
        )
        .padding(.top, config.paddings.outerTop)
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
    }
}

extension GetCollateralLandingFaqView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Product = GetCollateralLandingProduct
    typealias State = GetCollateralLandingDomain.State
}

// MARK: - Previews

struct GetCollateralLandingFaqView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingFaqView(
            product: .carStub,
            config: .preview
        )
    }
    
    static let carData = GetCollateralLandingProduct.carStub
    static let realEstateData = GetCollateralLandingProduct.realEstateStub
}
