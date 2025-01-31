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
    let externalEvents: (Domain.ExternalEvents) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: DomainState,
        event: @escaping (Event) -> Void,
        externalEvents: @escaping (Domain.ExternalEvents) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.externalEvents = externalEvents
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        Group {
            
            if state.isLoading {
                
                ProgressView()
            } else {
                
                content
            }
        }
        .if(state.stage == .confirm) {
        
            $0.navigationBarBackButtonHidden(true)
              .navigationBarItems(leading: buttonBack)
        }
    }
    
    var buttonBack : some View { Button(action: { event(.tappedBack) }) {
        HStack {
            Image(systemName: "chevron.left")
                .aspectRatio(contentMode: .fit)
            Text("Назад")
        }
    }
    }
    
    @ViewBuilder
    private var content: some View {
        
        VStack {
            
            ScrollView {

                headerView
                amountView
                periodView
                percentView
                cityView

                if state.stage == .confirm {

                    otpView
                    consentsView
                    consentsView
                }
            }
            .frame(maxHeight: .infinity)
            
            buttonView
        }
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    var headerView: some View {
        
        CreateDraftCollateralLoanApplicationHeaderView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    var amountView: some View {
        
        CreateDraftCollateralLoanApplicationAmountView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }

    var periodView: some View {
        
        CreateDraftCollateralLoanApplicationPeriodView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    var percentView: some View {

        CreateDraftCollateralLoanApplicationPercentView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }

    var cityView: some View {

        CreateDraftCollateralLoanApplicationCityView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }

    var buttonView: some View {

        CreateDraftCollateralLoanApplicationButtonView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }

    var otpView: some View {
        
        CreateDraftCollateralLoanApplicationOTPView(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }

    // TODO: Need to realize
    var consentsView: some View {
        
        CreateDraftCollateralLoanApplicationConsentsView(
            state: state,
            externalEvents: { externalEvents($0) },
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

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    public typealias Domain = CreateDraftCollateralLoanApplicationDomain
    public typealias DomainState = Domain.State
    public typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
    public typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

extension CreateDraftCollateralLoanApplicationDomain {
 
    public enum ExternalEvents: Equatable {
        
        case showConsent(URL)
    }
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: .correntParametersPreview,
            event: { print($0) },
            externalEvents: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")

        CreateDraftCollateralLoanApplicationView(
            state: .confirmPreview,
            event: { print($0) }, 
            externalEvents: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран отправки параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
