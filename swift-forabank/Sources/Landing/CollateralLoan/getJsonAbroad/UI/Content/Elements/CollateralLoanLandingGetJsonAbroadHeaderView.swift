//
//  CollateralLoanLandingGetJsonAbroadHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingGetJsonAbroadHeaderView: View {
    
    let labelTag: String
    let params: [String]
    let config: Config
    let theme: Theme

    public var body: some View {

        VStack {
            
            labelTag.text(
                withConfig: .init(
                    textFont: config.headerView.labelTag.fontConfig.font,
                    textColor: config.headerView.labelTag.fontConfig.foregroundColor
                )
            )
            .padding(.vertical, config.headerView.labelTag.verticalInnerPadding)
            .padding(.horizontal, config.headerView.labelTag.horizontalInnerPadding)
            .background(
                RoundedRectangle(cornerRadius: config.headerView.labelTag.cornerSize)
                    .fill(config.headerView.labelTag.fontConfig.backgroundColor)
            )
            .rotationEffect(Angle(degrees: config.headerView.labelTag.rotationDegrees))
            .padding(.leading, config.headerView.labelTag.leadingOuterPadding)
            .padding(.top, config.headerView.labelTag.topOuterPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: config.headerView.params.spacing) {
                ForEach(params, id: \.self) {
                    
                    "• \($0)".text(withConfig: .init(
                        textFont: config.fonts.body.font,
                        textColor: config.fonts.body.foregroundColor
                    ))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, config.headerView.params.topPadding)
            .padding(.leading, config.headerView.params.leadingPadding)

            Spacer()
        }
        .frame(height: config.headerView.height)
    }
}

public extension CollateralLoanLandingGetJsonAbroadHeaderView {
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}

// MARK: - Previews

struct CollateralLoanLandingGetJsonAbroadHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CollateralLoanLandingGetJsonAbroadView(
            content: content,
            factory: factory
        )
    }
    
    static let cardData = GetJsonAbroadData.cardStub
    static let realEstateData = GetJsonAbroadData.realEstateStub
    static let content = Content(data: cardData)
    static let factory = Factory()
    
    typealias Content = CollateralLoanLandingGetJsonAbroadContent
    typealias Factory = CollateralLoanLandingGetJsonAbroadViewFactory
}
