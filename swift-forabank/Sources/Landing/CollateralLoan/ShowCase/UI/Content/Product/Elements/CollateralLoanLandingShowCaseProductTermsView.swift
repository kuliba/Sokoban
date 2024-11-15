//
//  CollateralLoanLandingShowCaseProductTermsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseProductTermsView: View {

    public let params: Params
    public let config: Config
    public let theme: Theme
    
    public init(params: Params, config: Config, theme: Theme) {
        self.params = params
        self.config = config
        self.theme = theme
    }
    
    public var body: some View {
        
        HStack {
            
            rate(params.rate)
            Spacer()
            amount(params.amount)
            Spacer()
            Text("|")
                .font(config.fonts.body)
                .foregroundColor(theme.foregroundColor)
            Spacer()
            term(params.term)
        }
        .frame(height: config.termsView.height)
        .padding(.top, config.paddings.top)
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

private extension CollateralLoanLandingShowCaseProductTermsView {
    
    func rate(_ rate: String) -> some View {

        Text(rate)
            .font(config.fonts.body)
            .foregroundColor(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 15)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 255/255, green: 54/255, blue: 1/255)))
    }
    
    func amount(_ amount: String) -> some View {
        
        Text(amount)
            .font(config.fonts.body)
            .foregroundColor(theme.foregroundColor)
    }
    
    func term(_ term: String) -> some View {
        
        Text(term)
            .font(config.fonts.body)
            .foregroundColor(theme.foregroundColor)
    }
}

public extension CollateralLoanLandingShowCaseProductTermsView {
    
    typealias Params = CollateralLoanLandingShowCaseData.Product.KeyMarketingParams
    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
