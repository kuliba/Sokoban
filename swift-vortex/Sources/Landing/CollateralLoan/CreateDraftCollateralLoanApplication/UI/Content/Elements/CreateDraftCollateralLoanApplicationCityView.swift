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

struct CreateDraftCollateralLoanApplicationCityView: View {
    
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
            state: state.city,
            event: { event(.city($0)) },
            factory: .init(
                makeIconView: { factory.makeImageViewByMD5hash(state.data.icons.city) },
                makeItemLabel: { item in IconLabel(
                    text: item.title,
                    makeIconView: {
                        
                        Image(
                            systemName: isItemSelected(item)
                                          ? config.icons.selectedItem
                                          : config.icons.unselectedItem)
                    },
                    iconColor: isItemSelected(item) ? .red : .secondary
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
                id: .other(DomainState.FieldID.city.id),
                title: config.elements.city.title,
                value: state.data.selectedCity,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewByMD5hash(state.data.icons.city) }
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
    typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias IconView = UIPrimitives.AsyncImage
    typealias CityItem = CreateDraftCollateralLoanApplicationDomain.CityItem
    typealias SelectorView
        = OptionalSelectorView<CityItem, IconView, IconLabel<Image>, SelectedOptionView, ChevronView>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationCityView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationCityView(
            state: .correntParametersPreview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit mode")

        CreateDraftCollateralLoanApplicationCityView(
            state: .confirmPreview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Read only mode")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
