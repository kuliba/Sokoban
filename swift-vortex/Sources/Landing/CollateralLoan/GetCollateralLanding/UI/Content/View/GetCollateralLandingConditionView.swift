//
//  GetCollateralLandingConditionView.swift
//
//
//  Created by Valentin Ozerov on 13.12.2024.
//

import Combine
import SwiftUI

struct GetCollateralLandingConditionView: View{

    let condition: Condition
    let config: Config
    let makeImageViewWithMD5Hash: Factory.MakeImageViewWithMD5Hash

    var body: some View {
        
        HStack(spacing: 0) {

            iconView
            
            VStack(spacing: 0) {
                
                titleView
                subTitleView
                
                Spacer()
            }
        }
    }
}

private extension GetCollateralLandingConditionView {
    
    private var iconView: some View {
        
        VStack {
            
            makeImageViewWithMD5Hash(condition.icon)
                .frame(
                    width: config.list.layouts.iconSize.width,
                    height: config.list.layouts.iconSize.height
                )
                .padding(.trailing, config.list.layouts.iconTrailingPadding)
            
            Spacer()
        }
    }
    
    private var titleView: some View {
        
        condition.title.text(
            withConfig: .init(
                textFont: config.list.fonts.title.font,
                textColor: config.list.fonts.title.foreground
            )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subTitleView: some View {
        
        condition.subTitle.text(
            withConfig: .init(
                textFont: config.list.fonts.subTitle.font,
                textColor: config.list.fonts.subTitle.foreground
            )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, config.list.layouts.subTitleTopPadding)
    }
}

extension GetCollateralLandingConditionView {
    
    typealias Config = GetCollateralLandingConfig.Conditions
    typealias Theme = GetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
    typealias Condition = GetCollateralLandingProduct.Condition
    typealias Factory = GetCollateralLandingFactory
}

// MARK: - Previews

struct GetCollateralLandingConditionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingConditionView(
            condition: GetCollateralLandingProduct.carStub.conditions.first!,
            config: .default,
            makeImageViewWithMD5Hash: Factory.preview.makeImageViewWithMD5Hash
        )
        .padding(.top, 300)
        .padding(.horizontal, 16)
    }
    
    typealias Factory = GetCollateralLandingFactory
}
