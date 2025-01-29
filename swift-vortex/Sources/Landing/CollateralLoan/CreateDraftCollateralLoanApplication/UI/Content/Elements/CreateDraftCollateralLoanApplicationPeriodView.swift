//
//  CreateDraftCollateralLoanApplicationPeriodView.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import OptionalSelectorComponent
import PaymentComponents
import SwiftUI
import UIPrimitives

struct CreateDraftCollateralLoanApplicationPeriodView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        if state.stage == .correctParameters {
            
            editModeView
        } else {
          
            readOnlyModeView
        }
    }
    
    private var editModeView: some View {

        SelectorView(
            state: state.period,
            event: { event(.period($0)) },
            factory: .init(
                makeIconView: { factory.makeImageViewWithMD5hash(state.data.icons.term) },
                makeItemLabel: { item in IconLabel(
                    text: item.title,
                    makeIconView: { Image(systemName: isItemSelected(item) ? "record.circle" : "circle") },
                    iconColor: isItemSelected(item) ? .red : .secondary
                ) },
                makeSelectedItemLabel: { SelectedOptionView(optionTitle: $0.title) },
                makeToggleLabel: { state in
                    ChevronView(state: state, config: config.period.chevronViewConfig)
                }
            ),
            config: config.period.viewConfig
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
        
    private var readOnlyModeView: some View {
        
        InfoView(
            info: .init(
                id: .other(UUID().uuidString),
                title: config.period.title,
                value: state.data.selectedPeriodTitle,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5hash(state.data.icons.term) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationPeriodView {
    
    private func isItemSelected(_ item: PeriodItem) -> Bool {
        
        item == state.period.selected
    }
}

extension CreateDraftCollateralLoanApplicationPeriodView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias IconView = UIPrimitives.AsyncImage
    typealias PeriodItem = CreateDraftCollateralLoanApplicationDomain.PeriodItem
    typealias SelectorView
        = OptionalSelectorView<PeriodItem, IconView, IconLabel<Image>, SelectedOptionView, ChevronView>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationPeriodView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationPeriodView(
            state: .correntParametersPreview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
