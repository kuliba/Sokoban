//
//  GetCollateralLandingFooterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

struct GetCollateralLandingFooterView<InformerPayload>: View where InformerPayload: Equatable {
    
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
                .background(state.isButtonDisabled ? config.disabledBackground : config.background)
                .cornerRadius(12)
                .font(config.font.font)
        }
        .disabled(state.isButtonDisabled)
        .padding(config.layouts.paddings)
        .background(Color.white)
    }
}

extension GetCollateralLandingFooterView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent<InformerPayload>
    typealias State = GetCollateralLandingDomain.State<InformerPayload>
}

// MARK: - Previews

struct GetCollateralLandingFooterView_Previews<InformerPayload>: PreviewProvider
    where InformerPayload: Equatable {
    
    static var previews: some View {
        
        GetCollateralLandingFooterView<InformerPayload>(
            product: .carStub,
            config: GetCollateralLandingConfig.preview.footer,
            state: .init(landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE", formatCurrency: { _ in "" }),
            externalEvent: { print($0) }
        )
    }
}
