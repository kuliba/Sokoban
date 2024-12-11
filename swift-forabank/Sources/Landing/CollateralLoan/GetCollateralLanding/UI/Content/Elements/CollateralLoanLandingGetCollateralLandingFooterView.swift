//
//  CollateralLoanLandingGetCollateralLandingFooterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

import SwiftUI

struct CollateralLoanLandingGetCollateralLandingFooterView: View {
    
    private let config: Config.Footer
    private let theme: Theme
    private let action: Action
    
    init(config: Config, theme: Theme, action: @escaping Action) {
        
        self.config = config.footer
        self.theme = theme
        self.action = action
    }

    var body: some View {
        
        Button(action: action) {
            
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

extension CollateralLoanLandingGetCollateralLandingFooterView {
    
    typealias Config = CollateralLoanLandingGetCollateralLandingViewConfig
    typealias Theme = CollateralLoanLandingGetCollateralLandingTheme
    typealias Action = () -> Void
}

// MARK: - Previews

struct CollateralLoanLandingGetCollateralLandingFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CollateralLoanLandingGetCollateralLandingFooterView(
            config: .default,
            theme: .gray,
            action: {}
        )
    }
}
