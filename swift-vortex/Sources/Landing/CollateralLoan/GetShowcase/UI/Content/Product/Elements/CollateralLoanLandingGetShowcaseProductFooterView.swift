//
//  CollateralLoanLandingGetShowcaseProductFooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingGetShowcaseProductFooterView: View {
    
    let landingId: String
    let termsUrl: String
    let event: (GetShowcaseViewEvent.External) -> Void
    let config: Config
    let theme: Theme

    var body: some View {

        HStack(spacing: 4) {
            
            Button(action: { event(.showTerms(termsUrl)) }) {

                HStack(spacing: config.footerView.spacing) {
                    
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Подробные условия")
                        .multilineTextAlignment(.leading)
                }
            }
            .foregroundColor(theme.foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
            Button(action: { event(.showLanding(landingId)) }) {

                Text("Получить")
                    .font(config.fonts.body)
                    .foregroundColor(config.footerView.buttonForegroundColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 255/255, green: 54/255, blue: 54/255))
            .cornerRadius(10)
        }
        .frame(
            maxWidth: .infinity,
            idealHeight: config.footerView.height,
            maxHeight: config.footerView.height
        )
        .padding(.top, config.footerView.topPadding)
        .padding(.bottom, config.paddings.outer.vertical)
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

extension CollateralLoanLandingGetShowcaseProductFooterView {
    
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
    typealias Event = GetShowcaseDomain.Event
}
