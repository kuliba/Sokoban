//
//  CreateDraftCollateralLoanApplicationCityView.swift
//
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import OptionalSelectorComponent
import PaymentComponents
import SwiftUI
import UIPrimitives

struct CreateDraftCollateralLoanApplicationCityView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel{
    
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
            state: state.city,
            event: { event(.city($0)) },
            factory: .init(
                makeIconView: { factory.makeImageViewWithMD5Hash(state.application.icons.city) },
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
                    ChevronView(state: state, config: config.elements.city.cityConfig.chevron)
                }
            ),
            config: config.elements.city.cityConfig.selector
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
    
    private var readOnlyModeView: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.city.id),
                title: config.elements.city.title,
                value: state.selectedCity,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.application.icons.city) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationCityView {
    
    private func isItemSelected(_ item: CityItem) -> Bool {
        
        item == state.city.selected
    }
}

extension CreateDraftCollateralLoanApplicationCityView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
    typealias IconView = UIPrimitives.AsyncImage
    typealias CityItem = Domain.CityItem
    typealias SelectorView
        = OptionalSelectorView<CityItem, IconView, IconLabel<Image>, SelectedOptionView, ChevronView>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationCityView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationCityView<Confirmation, InformerPayload>(
            state: .init(application: .preview, stage: .correctParameters, formatCurrency: { _ in ""}),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit mode")

        CreateDraftCollateralLoanApplicationCityView<Confirmation, InformerPayload>(
            state: .init(application: .preview, stage: .confirm, formatCurrency: { _ in "" }),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Read only mode")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Application = CreateDraftCollateralLoanApplication
}
