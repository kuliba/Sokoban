//
//  CreateDraftCollateralLoanApplicationHeaderView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationHeaderView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.header.id),
                title: config.elements.header.title,
                value: state.application.name,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.application.icons.productName) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationHeaderView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationHeaderView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationHeaderView<Confirmation, InformerPayload>(
            state: .init(application: .preview),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
    }
}
