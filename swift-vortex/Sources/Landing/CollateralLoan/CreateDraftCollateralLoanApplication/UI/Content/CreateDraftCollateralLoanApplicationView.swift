//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

public struct CreateDraftCollateralLoanApplicationView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: DomainState,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        ScrollView {
            
            CreateDraftCollateralLoanApplicationHeaderView(
                state: state,
                event: event,
                config: config,
                factory: factory
            )
            
            Spacer()
        }
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    public typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    public typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
    public typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: .preview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
