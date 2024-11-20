//
//  CollateralLoanLandingGetJsonAbroadCalculatorView.swift
//  
//
//  Created by Valentin Ozerov on 19.11.2024.
//

import Foundation

import SwiftUI

struct CollateralLoanLandingGetJsonAbroadCalculatorView: View {
    
    // TODO: Replace on real data
    @State private var toggleIsOn = false
    @State private var sliderCurrentValue = 6.0
    
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
                calculatorBottomSectionView(config: config)
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
                
                periodView(config: config)
                percentView(config: config)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.top, config.middleSectionSpacing)

            depositView(config: config)
            desiredAmountView(config: config)
        }
    }
    
    private func calculatorBottomSectionView(config: Config) -> some View {

        ZStack {
            
            RoundedRectangle(cornerRadius: config.calculator.bottomPanelCornerRadius)
                .fill(config.calculator.bottomPanelBackgroundColor)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 0) {
                
                config.calculator.monthlyPaymentTitleText.text(
                    withConfig: .init(
                        textFont: config.calculator.titleFont.font,
                        textColor: config.calculator.titleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, config.calculator.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPaymentTitleTopPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
                
                // TODO: Replace on real data
                "35 099,28 ₽".text(
                    withConfig: .init(
                        textFont: config.calculator.valueFont.font,
                        textColor: config.calculator.valueFont.foreground
                    )
                )
                .padding(.leading, config.calculator.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPaymentValueTopPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                config.calculator.infoTitleText.text(
                    withConfig: .init(
                        textFont: config.calculator.titleFont.font,
                        textColor: config.calculator.titleFont.foreground
                    )
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, config.calculator.contentLeadingPadding)
                .padding(.trailing, config.calculator.contentTrailingPadding)
                .padding(.top, config.calculator.infoTitleTopPadding)
                .padding(.bottom, config.calculator.infoTitleBottomPadding)
            }
        }
    }
    
    private func periodView(config: Config.Calculator) -> some View {
        
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
                
                // TODO: Replace on real data
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
    }
    
    func percentView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {

            config.percentTitleText.text(
                withConfig: .init(
                    textFont: config.titleFont.font,
                    textColor: config.titleFont.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, config.spacingBetweenTitleAndValue)

            // TODO: Replace on real data
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
    
    func depositView(config: Config.Calculator) -> some View {
        
        Group {
            
            config.depositTitleText.text(
                withConfig: .init(
                    textFont: config.titleFont.font,
                    textColor: config.titleFont.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, config.depositTitleTopPadding)
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
        }
    }
    
    func desiredAmountView(config: Config.Calculator) -> some View {
        
        Group {
            
            config.desiredAmountTitleText.text(
                withConfig: .init(
                    textFont: config.titleFont.font,
                    textColor: config.titleFont.foreground
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, config.desiredAmountTitleTopPadding)
            .padding(.leading, config.contentLeadingPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                
                // TODO: Replace on real data
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
                
                config.desiredAmountMaxText.text(
                    withConfig: .init(
                        textFont: config.titleFont.font,
                        textColor: config.titleFont.foreground
                    )
                )
                .padding(.trailing, config.contentTrailingPadding)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
            
            // TODO: Need to customize
            Slider(value: $sliderCurrentValue, in: (0...20))
                .padding(.leading, config.contentLeadingPadding)
                .padding(.trailing, config.contentTrailingPadding)
                .padding(.bottom, config.sliderBottomPadding)
        }
    }
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
