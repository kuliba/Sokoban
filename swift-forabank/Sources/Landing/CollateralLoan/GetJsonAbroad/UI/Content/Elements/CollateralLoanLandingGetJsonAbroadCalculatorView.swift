//
//  CollateralLoanLandingGetJsonAbroadCalculatorView.swift
//  
//
//  Created by Valentin Ozerov on 19.11.2024.
//

import Foundation

import SwiftUI

struct CollateralLoanLandingGetJsonAbroadCalculatorView: View {
    
    @State private var toggleIsOn = false
    
    private let config: Config
    private let theme: Theme
    
    init(config: Config, theme: Theme) {
        self.config = config
        self.theme = theme
    }
    
    var body: some View {
        
        calculatorView
    }
    
    private var calculatorView: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(config.calculator.backgroundColor)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 0) {
                calculatorTopSectionView(config: config.calculator)
                calculatorMiddleSectionView(config: config.calculator)
//                calculatorBottomSectionView(config: config.calculator)
            }
        }
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
        .padding(.top, config.spacing)
    }
    
    private func calculatorTopSectionView(config: Config.Calculator) -> some View {

        VStack(spacing: 0) {
            config.headerText.text(
                withConfig: .init(
                    textFont: config.headerFont.font,
                    textColor: config.headerFont.foreground
                )
            )
            .padding(.top, config.headerTopPadding)
            .padding(.leading, config.contentLeadingPadding)
            .padding(.trailing, config.contentTrailingPadding)
            .padding(.bottom, config.headerBottomPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                config.salaryText.text(
                    withConfig: .init(
                        textFont: config.salaryFont.font,
                        textColor: config.salaryFont.foreground
                    )
                )
                .padding(.leading, config.salaryLeadingPadding)
                .padding(.trailing, config.salaryTrailingPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("", isOn: $toggleIsOn)
                    .toggleStyle(CalculatorToggleStyle(viewConfig: config))
                    .padding(.trailing, config.toggleTrailingPadding)
            }
            .padding(.bottom, config.salaryBottomPadding)
            
            Divider()
                .background(config.dividerColor)
                .padding(.leading, config.contentLeadingPadding)
                .padding(.trailing, config.contentTrailingPadding)
        }
    }
    
    private func calculatorMiddleSectionView(config: Config.Calculator) -> some View {
        
        VStack {
            
            HStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    config.periodTitleText.text(
                        withConfig: .init(
                            textFont: config.titleFont.font,
                            textColor: config.titleFont.foreground
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, config.spacingBetweenTitleAndValue)
                    .padding(.leading, config.contentLeadingPadding)
                    
                    HStack {
                        "3 года".text(
                            withConfig: .init(
                                textFont: config.valueFont.font,
                                textColor: config.valueFont.foreground
                            )
                        )
                        .padding(.leading, config.contentLeadingPadding)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(config.chevronColor)
                            .frame(width: 10.5, height: 10.5)
                            .padding(.leading, config.chevronSpacing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                VStack(spacing: 0) {

                    config.percentTitleText.text(
                        withConfig: .init(
                            textFont: config.titleFont.font,
                            textColor: config.titleFont.foreground
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, config.spacingBetweenTitleAndValue)

                    "16%".text(
                        withConfig: .init(
                            textFont: config.valueFont.font,
                            textColor: config.valueFont.foreground
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.top, config.middleSectionSpacing)
            
            config.depositTitleText.text(
                withConfig: .init(
                    textFont: config.titleFont.font,
                    textColor: config.titleFont.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, config.depositTopPadding)
            .padding(.leading, config.contentLeadingPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                "Иное движимое имущество".text(
                    withConfig: .init(
                        textFont: config.valueFont.font,
                        textColor: config.valueFont.foreground
                    )
                )
                .padding(.leading, config.contentLeadingPadding)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(config.chevronColor)
                    .frame(width: 10.5, height: 10.5)
                    .padding(.leading, config.chevronSpacing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            config.desiredAmountTitleText.text(
                withConfig: .init(
                    textFont: config.titleFont.font,
                    textColor: config.titleFont.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, config.desiredAmountTopPadding)
            .padding(.leading, config.contentLeadingPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                "1 325 457 ₽".text(
                    withConfig: .init(
                        textFont: config.valueFont.font,
                        textColor: config.valueFont.foreground
                    )
                )
                .padding(.leading, config.contentLeadingPadding)
                
                // TODO: change icon
                Image(systemName: "pencil")
                    .foregroundColor(config.chevronColor)
                    .frame(width: 10.5, height: 10.5)
                    .padding(.leading, config.chevronSpacing)
                
                config.desiredAmountTitleText.text(
                    withConfig: .init(
                        textFont: config.titleFont.font,
                        textColor: config.titleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
        }
    }
    
//    private func calculatorBottomSectionView(config: Config.Calculator) -> some View {
//        EmptyView()
//    }
}

extension CollateralLoanLandingGetJsonAbroadCalculatorView {
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}

// MARK: - Previews

struct CollateralLoanLandingGetJsonAbroadView_Previews: PreviewProvider {
    
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

private struct CalculatorToggleStyle: ToggleStyle {
    
    let viewConfig: CollateralLoanLandingGetJsonAbroadViewConfig.Calculator
    
    func makeBody(configuration: Configuration) -> some View {
    
        RoundedRectangle(cornerRadius: 16, style: .circular)
            .stroke(style: .init(lineWidth: 2))
            .fill(viewConfig.toggleColor)
            .frame(width: 51, height: 31)
            .overlay(
                Circle()
                    .fill(viewConfig.toggleColor)
                    .shadow(radius: 1, x: 0, y: 1)
                    .padding(4)
                    .offset(x: configuration.isOn ? 10 : -10)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    configuration.isOn.toggle()
                }
            }
    }
}
