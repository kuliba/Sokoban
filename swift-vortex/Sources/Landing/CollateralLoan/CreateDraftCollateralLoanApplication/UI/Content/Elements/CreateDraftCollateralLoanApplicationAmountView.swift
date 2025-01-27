//
//  CreateDraftCollateralLoanApplicationAmountView.swift
//
//
//  Created by Valentin Ozerov on 23.01.2025.
//

import SwiftUI
import PaymentComponents

struct CreateDraftCollateralLoanApplicationAmountView<InputView>: View
    where InputView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let inputView: InputView

    var body: some View {
        
        inputView
            .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationAmountView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationAmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationAmountView(
            state: .preview,
            event: { print($0) },
            config: .default,
            factory: .preview,
            inputView: Text("InputView")
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
