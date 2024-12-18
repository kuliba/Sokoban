//
//  GetCollateralLandingFooterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

struct GetCollateralLandingFooterView: View {
    
    let config: Config.Footer
    let state: GetCollateralLandingState
    let event: (Event) -> Void

    var body: some View {
        
        Button(action: { event(.createDraftApplication) }) {
            
            Text(config.text)
                .frame(maxWidth: .infinity)
                .frame(height: config.layouts.height)
                .foregroundColor(config.foreground)
                .background(config.background)
                .cornerRadius(12)
                .font(config.font.font)
        }
        .padding(.leading, config.layouts.paddings.leading)
        .padding(.trailing, config.layouts.paddings.trailing)
        .padding(.top, config.layouts.paddings.top)
        .padding(.bottom, config.layouts.paddings.bottom)
    }
}

extension GetCollateralLandingFooterView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias Event = GetCollateralLandingEvent
}

// MARK: - Previews

struct GetCollateralLandingFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingFooterView(
            config: .default,
            state: .init(product: .carStub),
            event: { print($0) }
        )
    }
}
