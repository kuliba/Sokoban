//
//  CreateDraftCollateralLoanApplicationPercentView.swift
//
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationPercentView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.percent.id),
                title: config.elements.percent.title,
                value: state.data.formattedPercent,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.data.icons.rate) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationPercentView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Confirmation = Domain.Confirmation
    typealias State = Domain.State<Confirmation>
    typealias Event = Domain.Event<Confirmation>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationPercentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationPercentView(
            state: .init(
                data: .preview,
                stage: .correctParameters,
                confirmation: .preview
            ),
            event: {
                print($0)
            },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit only mode")

        CreateDraftCollateralLoanApplicationPercentView(
            state: .init(
                data: .preview,
                stage: .confirm,
                confirmation: .preview
            ),
            event: {
                print($0)
            },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Read only only mode")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
