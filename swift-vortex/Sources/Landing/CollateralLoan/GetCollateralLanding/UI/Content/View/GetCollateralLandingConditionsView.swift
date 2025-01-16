//
//  GetCollateralLandingConditionsView.swift
//
//
//  Created by Valentin Ozerov on 15.11.2024.
//

import Combine
import SwiftUI
import UIPrimitives

struct GetCollateralLandingConditionsView: View {
    
    let state: State
    let config: Config
    let makeImageView: Factory.MakeImageView
    
    var body: some View {
        
        conditionsView
    }
    
    private var conditionsView: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(config.conditions.list.colors.background)
                .frame(maxWidth: .infinity)
            
            conditionsListView(config.conditions)
        }
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
    }
    
    private func conditionsListView(_ config: Config.Conditions) -> some View {
                
        VStack {
        
            config.header.text.text(
                withConfig: .init(
                    textFont: config.header.headerFont.font,
                    textColor: config.header.headerFont.foreground
                )
            )
            .padding(.horizontal, config.list.layouts.horizontalPadding)
            .padding(.vertical, config.list.layouts.listTopPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                
                ForEach(state.product.conditions, id: \.title) {
                    
                    GetCollateralLandingConditionView(
                        condition: $0,
                        config: config,
                        makeImageView: makeImageView
                    )
                }
                .padding(.horizontal, config.list.layouts.horizontalPadding)
                .padding(.bottom, config.list.layouts.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, config.list.layouts.listTopPadding)
        }
    }
    
    private func conditionView(_ condition: Condition, config: Config.Conditions) -> some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                // simulacrum
                Circle()
                    .fill(config.list.colors.iconBackground)
                    .frame(
                        width: config.list.layouts.iconSize.width,
                        height: config.list.layouts.iconSize.height
                    )
                    .padding(.trailing, config.list.layouts.iconTrailingPadding)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                condition.title.text(
                    withConfig: .init(
                        textFont: config.list.fonts.title.font,
                        textColor: config.list.fonts.title.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                condition.subTitle.text(
                    withConfig: .init(
                        textFont: config.list.fonts.subTitle.font,
                        textColor: config.list.fonts.subTitle.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, config.list.layouts.subTitleTopPadding)
                
                Spacer()
            }
        }
    }
}

extension GetCollateralLandingConditionsView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias Condition = GetCollateralLandingProduct.Condition
    typealias Factory = GetCollateralLandingFactory
    typealias State = GetCollateralLandingDomain.State
}

// MARK: - Previews

struct GetCollateralLandingConditionsView_Previews: PreviewProvider {

    static var previews: some View {

            GetCollateralLandingConditionsView(
                state: .init(product: .carStub),
                config: .default,
                makeImageView: Factory.preview.makeImageView
            )
            .frame(height: 100)
    }

    typealias Factory = GetCollateralLandingFactory
}
