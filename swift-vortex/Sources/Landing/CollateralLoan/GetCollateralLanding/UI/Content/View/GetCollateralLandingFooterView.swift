//
//  GetCollateralLandingFooterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

struct GetCollateralLandingFooterView: View {
    
    let product: Product
    let config: Config.Footer
    let state: State
    let externalEvent: (ExternalEvent) -> Void

    var body: some View {
        
        Button(action: { externalEvent(.createDraftApplication(product)) }) {
            
            Text(config.text)
                .frame(maxWidth: .infinity)
                .frame(height: config.layouts.height)
                .foregroundColor(config.foreground)
                .background(config.background)
                .cornerRadius(12)
                .font(config.font.font)
        }
        .padding(config.layouts.paddings)
        .background(Color.white)
    }
}

extension GetCollateralLandingFooterView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent
    typealias State = GetCollateralLandingDomain.State
}

// MARK: - Previews

struct GetCollateralLandingFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingFooterView(
            product: .carStub,
            config: .default,
            state: .init(landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"),
            externalEvent: { print($0) }
        )
    }
}
