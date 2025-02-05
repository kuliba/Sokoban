//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import OTPInputComponent

public struct CreateDraftCollateralLoanApplicationView: View {
    
    let state: State
    let event: (Event) -> Void
    let externalEvent: (Domain.ExternalEvent) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        externalEvent: @escaping (Domain.ExternalEvent) -> Void,
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

                    if let optViewModel = state.confirmation?.otpViewModel {

                        otpView(otpViewModel: optViewModel)
                    }
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

    func otpView(otpViewModel: TimedOTPInputViewModel) -> some View {
        
        CreateDraftCollateralLoanApplicationOTPView(
            state: state,
            event: event,
            config: config,
            factory: factory,
            otpViewModel: otpViewModel
        )
    }

    var consentsView: some View {
        
        CreateDraftCollateralLoanApplicationConsentsView(
            state: state,
            event: event,
            externalEvent: { externalEvent($0) },
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
    public typealias Confirmation = Domain.Confirmation
    public typealias State = Domain.State<Confirmation>
    public typealias Event = Domain.Event<Confirmation>
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
    public typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

extension CreateDraftCollateralLoanApplicationDomain {
 
    public enum ExternalEvent: Equatable {
        
        case showConsent(URL)
    }
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: .init(
                data: .preview,
                stage: .correctParameters,
                confirmation: .preview
            ),
            event: {
                print($0)
            },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")

        CreateDraftCollateralLoanApplicationView(
            state: .init(
                data: .preview,
                stage: .confirm,
                confirmation: .preview
            ),
            event: { print($0) },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран отправки параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
