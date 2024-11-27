//
//  CollateralLoanLandingGetShowcaseProductFooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingGetShowcaseProductFooterView: View {
    
    let config: Config
    let theme: Theme

    var body: some View {

        HStack(spacing: 4) {
            
            HStack(spacing: 12) {

                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Подробные условия")
            }
            .foregroundColor(theme.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
            HStack {

                Text("Получить")
                    .font(config.fonts.body)
                    .foregroundColor(theme.foregroundColor)
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
        .padding(.bottom, config.paddings.outer.vertical)
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

extension CollateralLoanLandingGetShowcaseProductFooterView {
    
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
}
