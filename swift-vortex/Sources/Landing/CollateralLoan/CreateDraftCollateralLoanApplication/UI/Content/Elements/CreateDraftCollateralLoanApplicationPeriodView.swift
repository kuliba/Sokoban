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
    
    let state: State
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
                makeIconView: { factory.makeImageViewWithMD5Hash(state.data.icons.term) },
                makeItemLabel: { item in IconLabel(
                    text: item.title,
                    image: isItemSelected(item)
                        ? config.icons.selectedItem
                        : config.icons.unselectedItem,
                    iconColor: isItemSelected(item)
                        ? config.colors.selected
                        : config.colors.unselected
                ) },
                makeSelectedItemLabel: { SelectedOptionView(optionTitle: $0.title) },
                makeToggleLabel: { state in
                    ChevronView(state: state, config: config.elements.period.periodConfig.chevron)
                }
            ),
            config: config.elements.period.periodConfig.selector
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
        
    private var readOnlyModeView: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.period.id),
                title: config.elements.period.title,
                value: state.data.selectedPeriodTitle,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.data.icons.term) }
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
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Confirmation = Domain.Confirmation
    typealias State = Domain.State<Confirmation>
    typealias Event = Domain.Event<Confirmation>
    typealias IconView = UIPrimitives.AsyncImage
    typealias PeriodItem = Domain.PeriodItem
    typealias SelectorView
        = OptionalSelectorView<PeriodItem, IconView, IconLabel<Image>, SelectedOptionView, ChevronView>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationPeriodView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationPeriodView(
            state: .init(
                data: .preview,
                confirmation: .preview
            ),
            event: {
                print($0)
            },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
