//
//  CreateDraftCollateralLoanApplicationAmountView.swift
//
//
//  Created by Valentin Ozerov on 23.01.2025.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationAmountView: View {
    
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
            iconView: { factory.makeImageViewWithMD5Hash(state.data.icons.amount) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
    
    private var readOnlyModeView: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.amount.id),
                title: config.elements.amount.title,
                value: state.data.formattedAmount,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.data.icons.amount) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationAmountView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias State = CreateDraftCollateralLoanApplicationDomain.State<TimedOTPInputViewModel>
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationAmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationAmountView(
            state: .correntParametersPreview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit mode")

        CreateDraftCollateralLoanApplicationAmountView(
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
