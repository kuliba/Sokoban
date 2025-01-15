//
//  GetCollateralLandingCalculatorView.swift
//
//
//  Created by Valentin Ozerov on 19.11.2024.
//

import Foundation
import SwiftUI
import ToggleComponent

struct GetCollateralLandingCalculatorView: View {
    
    @State private var toggleIsOn = false
    @State private var sliderCurrentValue: Double = 6.0
    
    let state: GetCollateralLandingDomain.State
    let config: Config
    let domainEvent: (DomainEvent) -> Void
    let externalEvent: (ExternalEvent) -> Void

    var body: some View {
        
        calculatorView
    }
    
    private var calculatorView: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(config.calculator.root.colors.background)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 0) {
                
                calculatorTopSectionView(config: config.calculator)
                calculatorMiddleSectionView(config: config.calculator)
                calculatorBottomSectionView(config: config)
            }
        }
        .frame(height: config.calculator.root.layouts.height)
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
        .padding(.top, config.spacing)
    }
    
    private func calculatorTopSectionView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {
            
            headerText(config: config)
                .padding(.top, config.header.topPadding)
                .padding(.leading, config.root.layouts.contentLeadingPadding)
                .padding(.trailing, config.root.layouts.contentTrailingPadding)
                .padding(.bottom, config.header.bottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                
                salaryText(config: config)
                    .padding(.leading, config.salary.leadingPadding)
                    .padding(.trailing, config.salary.trailingPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("", isOn: $toggleIsOn)
                    .toggleStyle(ToggleComponentStyle(config: config.salary.toggle))
                    .onChange(of: toggleIsOn) { state in
                        
                        domainEvent(.toggleIHaveSalaryInCompany(state))
                    }
                    .padding(.trailing, config.salary.toggleTrailingPadding)
            }
            .padding(.bottom, config.salary.bottomPadding)
            
            Divider()
                .background(config.root.colors.divider)
                .padding(.leading, config.root.layouts.contentLeadingPadding)
                .padding(.trailing, config.root.layouts.contentTrailingPadding)
        }
    }
    
    private func calculatorMiddleSectionView(config: Config.Calculator) -> some View {
        
        VStack {
            
            HStack(spacing: 0) {
                
                periodView(config: config)
                percentView(config: config)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.top, config.root.layouts.middleSectionSpacing)
            
            depositView(config: config)
            desiredAmountView(config: config)
        }
    }
    
    private func calculatorBottomSectionView(config: Config) -> some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.calculator.root.layouts.bottomPanelCornerRadius)
                .fill(config.calculator.root.colors.bottomPanelBackground)
                .frame(maxWidth: .infinity)
            
            calculatorBottomContentView(config: config)
        }
    }
    
    private func calculatorBottomContentView(config: Config) -> some View {

        VStack(spacing: 0) {
            
            monthlyPaymentTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, config.calculator.root.layouts.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPayment.titleTopPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            monthlyPaymentValueText(config: config)
                .padding(.leading, config.calculator.root.layouts.contentLeadingPadding)
                .padding(.top, config.calculator.monthlyPayment.valueTopPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            config.calculator.info.titleText.text(
                withConfig: .init(
                    textFont: config.calculator.root.fonts.title.font,
                    textColor: config.calculator.root.fonts.title.foreground
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, config.calculator.root.layouts.contentLeadingPadding)
            .padding(.trailing, config.calculator.root.layouts.contentTrailingPadding)
            .padding(.top, config.calculator.info.titleTopPadding)
            .padding(.bottom, config.calculator.info.titleBottomPadding)
        }
    }
    
    private func periodView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {
            
            periodTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, config.root.layouts.spacingBetweenTitleAndValue)
                .padding(.leading, config.root.layouts.contentLeadingPadding)
            
            HStack {
                
                periodValueText(config: config)
                    .padding(.leading, config.root.layouts.contentLeadingPadding)
                
                chevron(config: config)
                    .onTapGesture {
                        externalEvent(.showCaseList(.period))
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    private func percentView(config: Config.Calculator) -> some View {
        
        VStack(spacing: 0) {
            
            percentTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, config.root.layouts.spacingBetweenTitleAndValue)
            
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
                .padding(.leading, config.root.layouts.contentLeadingPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                
                depositValueText(config: config)
                    .padding(.leading, config.root.layouts.contentLeadingPadding)

                chevron(config: config)
                    .onTapGesture {
                        externalEvent(.showCaseList(.deposit))
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func desiredAmountView(config: Config.Calculator) -> some View {
        
        Group {
            
            desiredAmountTitleText(config: config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, config.desiredAmount.titleTopPadding)
                .padding(.leading, config.root.layouts.contentLeadingPadding)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                
                desiredAmountValueText(config: config)
                    .padding(.leading, config.root.layouts.contentLeadingPadding)
                
                desiredAmountMaxText(config: config)
                    .padding(.trailing, config.root.layouts.contentTrailingPadding)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
            
            sliderView(config: config)
        }
    }
    
    private func sliderView(config: Config.Calculator) -> some View {
        
        SliderView(
            value: $sliderCurrentValue,
            maximumValue: config.salary.slider.maximumValue,
            minTrackColor: UIColor(config.salary.slider.minTrackColor),
            maxTrackColor: UIColor(config.salary.slider.maxTrackColor),
            thumbDiameter: config.salary.slider.thumbDiameter,
            trackHeight: config.salary.slider.trackHeight
        )
        .onChange(of: sliderCurrentValue, perform: {
            
            domainEvent(.changeDesiredAmount(UInt($0)))
        })
        .padding(.leading, config.root.layouts.contentLeadingPadding)
        .padding(.trailing, config.root.layouts.contentTrailingPadding)
        .padding(.bottom, config.desiredAmount.sliderBottomPadding)
    }
    
    private func chevron(config: Config.Calculator) -> some View {
        
        Image(systemName: "chevron.down")
            .foregroundColor(config.root.colors.chevron)
            .frame(width: 10.5, height: 10.5)
            .padding(.leading, config.root.layouts.chevronSpacing)
            .offset(y: config.root.layouts.chevronOffsetY)
    }
    
    // MARK: Content Subviews
    
    private func headerText(config: Config.Calculator) -> some View {
        
        formatText(config.header.text, with: config.header.font)
    }
    
    private func salaryText(config: Config.Calculator) -> some View {
        
        formatText(config.salary.text, with: config.salary.font)
    }
    
    private func monthlyPaymentTitleText(config: Config) -> some View {
        
        formatText(config.calculator.monthlyPayment.titleText, with: config.calculator.root.fonts.title)
    }
    
    private func monthlyPaymentValueText(config: Config) -> some View {
        
        // TODO: Replace on real data
        formatText("35 099,28 ₽", with: config.calculator.root.fonts.value)
    }
    
    private func periodTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.period.titleText, with: config.root.fonts.title)
    }
    
    private func periodValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("3 года", with: config.root.fonts.value)
    }
    
    private func percentTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.percent.titleText, with: config.root.fonts.title)
    }
    
    private func percentValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("16%", with: config.root.fonts.value)
    }
    
    private func depositTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.deposit.titleText, with: config.root.fonts.title)
    }
    
    private func depositValueText(config: Config.Calculator) -> some View {
        
        formatText("Иное движимое имущество", with: config.root.fonts.value)
    }
    
    private func desiredAmountTitleText(config: Config.Calculator) -> some View {
        
        formatText(config.desiredAmount.titleText, with: config.root.fonts.title)
    }
    
    private func desiredAmountValueText(config: Config.Calculator) -> some View {
        
        // TODO: Replace on real data
        formatText("1 325 457 ₽", with: config.desiredAmount.fontValue)
    }
    
    private func desiredAmountMaxText(config: Config.Calculator) -> some View {
        
        formatText(config.desiredAmount.maxText, with: config.root.fonts.title)
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

extension GetCollateralLandingCalculatorView {
    
    typealias Config = GetCollateralLandingConfig
    typealias Theme = GetCollateralLandingTheme
    typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent
    typealias DomainEvent = GetCollateralLandingDomain.Event
}

// MARK: - Previews

struct CollateralLoanLandingGetCollateralLandingCalculatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingCalculatorView(
            state: .init(landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"),
            config: .default,
            domainEvent: { print($0) },
            externalEvent: { print($0) }
        )
    }
}
