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
            
            headerText(config: config)
                .padding(.top, config.header.topPadding)
                .padding(.leading, config.contentLeadingPadding)
                .padding(.trailing, config.contentTrailingPadding)
                .padding(.bottom, config.header.bottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                
                salaryText(config: config)
                    .padding(.leading, config.salary.leadingPadding)
                    .padding(.trailing, config.salary.trailingPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("", isOn: $toggleIsOn)
                    .toggleStyle(CalculatorToggleStyle(viewConfig: config))
                    .padding(.trailing, config.salary.toggleTrailingPadding)
            }
            .padding(.bottom, config.salary.bottomPadding)
            
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
            
            calculatorBottomContentView(config: config)
        }
    }
    
    private func calculatorBottomContentView(config: Config) -> some View {

        VStack(spacing: 0) {
            
            monthlyPaymentTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, config.calculator.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPayment.titleTopPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            monthlyPaymentValueText(config: config)
                .padding(.leading, config.calculator.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPayment.valueTopPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            config.calculator.info.titleText.text(
                withConfig: .init(
                    textFont: config.calculator.titleFont.font,
                    textColor: config.calculator.titleFont.foreground
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, config.calculator.contentLeadingPadding)
            .padding(.trailing, config.calculator.contentTrailingPadding)
            .padding(.top, config.calculator.info.titleTopPadding)
            .padding(.bottom, config.calculator.info.titleBottomPadding)
        }
    }
    
    private func periodView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {
            
            periodTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, config.spacingBetweenTitleAndValue)
                .padding(.leading, config.contentLeadingPadding)
            
            HStack {
                
                periodValueText(config: config)
                    .padding(.leading, config.contentLeadingPadding)
                
                chevron(config: config)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    private func percentView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {
            
            percentTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, config.spacingBetweenTitleAndValue)
            
            percentValueText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    private func depositView(config: Config.Calculator) -> some View {
        
        Group {
            
            depositTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, config.deposit.titleTopPadding)
                .padding(.leading, config.contentLeadingPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                
                depositValueText(config: config)
                    .padding(.leading, config.contentLeadingPadding)

                chevron(config: config)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func desiredAmountView(config: Config.Calculator) -> some View {
        
        Group {
            
            desiredAmountTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, config.desiredAmount.titleTopPadding)
                .padding(.leading, config.contentLeadingPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                
                desiredAmountValueText(config: config)
                    .padding(.leading, config.contentLeadingPadding)
                
                // TODO: change icon
                Image(systemName: "pencil")
                    .foregroundColor(config.chevronColor)
                    .frame(width: 10.5, height: 10.5)
                    .padding(.leading, config.chevronSpacing)
                
                desiredAmountMaxText(config: config)
                    .padding(.trailing, config.contentTrailingPadding)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
            
            // TODO: Need to customize
            Slider(value: $sliderCurrentValue, in: (0...20))
                .padding(.leading, config.contentLeadingPadding)
                .padding(.trailing, config.contentTrailingPadding)
                .padding(.bottom, config.desiredAmount.sliderBottomPadding)
        }
    }
    
    private func chevron(config: Config.Calculator) -> some View {
        
        Image(systemName: "chevron.down")
            .foregroundColor(config.chevronColor)
            .frame(width: 10.5, height: 10.5)
            .padding(.leading, config.chevronSpacing)
    }
    
    // MARK: Content Subviews
    
    private func headerText(config: Config.Calculator) -> some View {
        
        formatText(config.header.text, with: config.header.font)
    }
    
    private func salaryText(config: Config.Calculator) -> some View {
        
        formatText(config.salary.text, with: config.salary.font)
    }
    
    private func monthlyPaymentTitleText(config: Config) -> some View {
        
        formatText(config.calculator.monthlyPayment.titleText, with: config.calculator.titleFont)
    }
    
    private func monthlyPaymentValueText(config: Config) -> some View {
        
        // TODO: Replace on real data
        formatText("35 099,28 ₽", with: config.calculator.valueFont)
    }
    
    private func periodTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.period.titleText, with: config.titleFont)
    }
    
    private func periodValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("3 года", with: config.valueFont)
    }
    
    private func percentTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.percent.titleText, with: config.titleFont)
    }
    
    private func percentValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("16%", with: config.valueFont)
    }
    
    private func depositTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.deposit.titleText, with: config.titleFont)
    }
    
    private func depositValueText(config: Config.Calculator) -> some View {
        
        formatText("Иное движимое имущество", with: config.valueFont)
    }
    
    private func desiredAmountTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.desiredAmount.titleText, with: config.titleFont)
    }
    
    private func desiredAmountValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("1 325 457 ₽", with: config.valueFont)
    }
    
    private func desiredAmountMaxText(config: Config.Calculator) -> some View {
        
        formatText(config.desiredAmount.maxText, with: config.titleFont)
    }
    
    // MARK: Helpers
    
    private func formatText(_ text: String, with fontConfig: Config.FontConfig) -> some View {
        
        text.text(
            withConfig: .init(
                textFont: fontConfig.font,
                textColor: fontConfig.foreground
            )
        )
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
            .fill(viewConfig.salary.toggleColor)
            .frame(width: 51, height: 31)
            .overlay(
                Circle()
                    .fill(viewConfig.salary.toggleColor)
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
