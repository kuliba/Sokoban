//
//  CollateralLoanLandingShowCaseProductTermsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseProductTermsView: View {

    let params: Params
    let config: Config
    let theme: Theme
    
    var body: some View {
        
        HStack {
            params.rate.map { rate($0) }
            Spacer()
            params.amount.map { amount($0) }
            Spacer()
            Text("|")
                .font(config.fonts.body)
                .foregroundColor(theme.foregroundColor)
            Spacer()
            params.term.map { term($0) }
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

extension CollateralLoanLandingShowCaseProductTermsView {
    
    typealias Params = CollateralLoanLandingShowCaseUIModel.Product.KeyMarketingParams
    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
