//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI

public struct CreateDraftCollateralLoanApplicationView<InputView>: View
    where InputView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let inputView: InputView
    
    public init(
        state: DomainState,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory,
        inputView: InputView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.inputView = inputView
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
                
                CreateDraftCollateralLoanApplicationAmountView(
                    state: state,
                    event: event,
                    config: config,
                    factory: factory,
                    inputView: inputView
                )
            }
            .frame(maxHeight: .infinity)
        }
        
        CreateDraftCollateralLoanApplicationButtonView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
}

struct FrameWithCornerRadiusModifier: ViewModifier {
    
    let config: CreateDraftCollateralLoanApplicationConfig
    
    func body(content: Content) -> some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.layouts.cornerRadius)
                .fill(config.colors.background)
                .frame(maxWidth: .infinity)
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(config.layouts.paddings.contentStack)
        }
        .padding(config.layouts.paddings.stack)
        .fixedSize(horizontal: false, vertical: true)
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
            factory: .preview,
            inputView: Text("InputView")
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
