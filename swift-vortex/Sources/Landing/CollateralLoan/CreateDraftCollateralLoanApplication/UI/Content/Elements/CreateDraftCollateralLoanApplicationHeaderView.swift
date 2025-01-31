//
//  CreateDraftCollateralLoanApplicationHeaderView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationHeaderView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        InfoView(
            info: .init(
                id: .other(State.FieldID.header.id),
                title: config.elements.header.title,
                value: state.data.name,
                style: .expanded
            ),
            config: .init(title: config.fonts.title, value: config.fonts.value),
            icon: { factory.makeImageViewWithMD5Hash(state.data.icons.productName) }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationHeaderView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias State = CreateDraftCollateralLoanApplicationDomain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationHeaderView(
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
