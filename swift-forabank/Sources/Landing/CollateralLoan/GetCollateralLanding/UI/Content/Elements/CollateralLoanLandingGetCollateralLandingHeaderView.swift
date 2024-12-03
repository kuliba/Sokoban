//
//  CollateralLoanLandingGetCollateralLandingHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingGetCollateralLandingHeaderView: View {
    
    let labelTag: String
    let params: [String]
    let config: Config
    let theme: Theme

    public var body: some View {

        headerView
    }
    
    private var headerView: some View {
        
        VStack {
            
            labelTagView(config: config.header.labelTag)
            paramsView(config: config.header.params, fonts: config.fonts)

            Spacer()
        }
        .frame(height: config.header.height)
    }
    
    private func labelTagView(config: Config.Header.LabelTag) -> some View {
        
        labelTag.text(
            withConfig: .init(
                textFont: config.fonts.fontConfig.font,
                textColor: config.fonts.fontConfig.foreground
            )
        )
        .padding(.vertical, config.layouts.verticalInnerPadding)
        .padding(.horizontal, config.layouts.horizontalInnerPadding)
        .background(
            RoundedRectangle(cornerRadius: config.layouts.cornerSize)
                .fill(config.fonts.fontConfig.background)
        )
        .rotationEffect(Angle(degrees: config.layouts.rotationDegrees))
        .padding(.leading, config.layouts.leadingOuterPadding)
        .padding(.top, config.layouts.topOuterPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func paramsView(
        config: Config.Header.Params,
        fonts: Config.Fonts
    ) -> some View {
        
        VStack(spacing: config.spacing) {
            ForEach(params, id: \.self) {
                
                "• \($0)".text(withConfig: .init(
                    textFont: fonts.body.font,
                    textColor: fonts.body.foreground
                ))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, config.topPadding)
        .padding(.leading, config.leadingPadding)
    }
}

public extension CollateralLoanLandingGetCollateralLandingHeaderView {
    
    typealias Config = CollateralLoanLandingGetCollateralLandingViewConfig
    typealias Theme = CollateralLoanLandingGetCollateralLandingTheme
}
