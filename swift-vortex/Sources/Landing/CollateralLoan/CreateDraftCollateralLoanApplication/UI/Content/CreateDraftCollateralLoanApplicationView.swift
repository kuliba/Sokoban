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
    let externalEvent: (ExternalEvent) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: DomainState,
        event: @escaping (Event) -> Void,
        externalEvent: @escaping (ExternalEvent) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.externalEvent = externalEvent
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        if state.isLoading {
            
            ProgressView()
        } else {
        
            content
        }
    }
        
    @ViewBuilder
    private var content: some View {
        
        VStack {
            
            ScrollView {
                
                CreateDraftCollateralLoanApplicationHeaderView(
                    state: state,
                    event: event,
                    config: config,
                    factory: factory
                )
            }
            .frame(maxHeight: .infinity)
        }
        .onChange(of: state.saveConsentsResult) { saveConsentsResult in
  
            guard let saveConsentsResult else { return }
            externalEvent(.showSaveConsentsResult(saveConsentsResult))
        }
        
        CreateDraftCollateralLoanApplicationButtonView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    public typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    public typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    public typealias ExternalEvent = CreateDraftCollateralLoanApplicationDomain.ExternalEvent
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
    public typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: .preview,
            event: { print($0) },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
