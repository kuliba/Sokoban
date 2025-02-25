//
//  CreateDraftCollateralLoanApplicationPercentView.swift
//
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationPercentView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.percent.id),
                title: config.elements.percent.title,
                value: state.application.formattedPercent,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.application.icons.rate) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationPercentView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationPercentView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationPercentView<Confirmation, InformerPayload>(
            state: .init(application: .preview, stage: .correctParameters, formatCurrency: { _ in "" }),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit only mode")

        CreateDraftCollateralLoanApplicationPercentView<Confirmation, InformerPayload>(
            state: .init(application: .preview, stage: .confirm, formatCurrency: { _ in "" }),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Read only only mode")
    }
}
