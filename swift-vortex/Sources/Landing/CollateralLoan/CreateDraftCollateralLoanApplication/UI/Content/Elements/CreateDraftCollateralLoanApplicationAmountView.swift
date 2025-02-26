//
//  CreateDraftCollateralLoanApplicationAmountView.swift
//
//
//  Created by Valentin Ozerov on 23.01.2025.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationAmountView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel {
    
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
        
        TextInputView(
            state: state.amount,
            event: { event(.amount($0)) },
            config: config.elements.amount.inputComponentConfig,
            iconView: { factory.makeImageViewWithMD5Hash(state.application.icons.amount) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
    
    private var readOnlyModeView: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.amount.id),
                title: config.elements.amount.title,
                value: state.formattedAmount ?? "",
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.application.icons.amount) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationAmountView {
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationAmountView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationAmountView<Confirmation, InformerPayload>(
            state: .init(application: .preview, formatCurrency: { _ in "" }),
            event: { print($0) },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Applicaton = CreateDraftCollateralLoanApplication
}
