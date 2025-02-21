//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import OTPInputComponent

public struct CreateDraftCollateralLoanApplicationView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel {
    
    @SwiftUI.State private var shimmeringEnabled = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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

            ScrollView() {
                
                applicationForm()
            }
            .safeAreaInset(edge: .bottom, content: buttonView)
    }
    
    @ViewBuilder
    private func applicationForm() -> some View {
        
        ScrollView {

            VStack {

                Group {
                    headerView()
                    amountView()
                    periodView()
                    percentView()
                    cityView()
                }
                .disabled(state.confirmation != nil)
                
                confirmationView()
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    private func confirmationView() -> some View {
        
        Group {
            
            if shimmeringEnabled {
                
                if state.stage == .confirm {
                    
                    shimmeringView()
                        .padding(config.layouts.paddings.contentStack)
                }
            } else {
                
                state.confirmation.map { confirmView(otpViewModel: $0) }
            }
        }
        .onReceive(timer) { _ in shimmeringEnabled = state.confirmation == nil }
    }
    
    private func confirmView(otpViewModel: TimedOTPInputViewModel) -> some View {
        
        Group {
            
            otpView(otpViewModel: otpViewModel)
            consentsView()
        }
    }
    
    private func headerView() -> some View {
        
        CreateDraftCollateralLoanApplicationHeaderView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func amountView() -> some View {
        
        CreateDraftCollateralLoanApplicationAmountView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func periodView() -> some View {
        
        CreateDraftCollateralLoanApplicationPeriodView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func percentView() -> some View {
        
        CreateDraftCollateralLoanApplicationPercentView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func cityView() -> some View {
        
        CreateDraftCollateralLoanApplicationCityView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func buttonView() -> some View {
        
        CreateDraftCollateralLoanApplicationButtonView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory
        )
    }
    
    func otpView(otpViewModel: TimedOTPInputViewModel) -> some View {
        
        CreateDraftCollateralLoanApplicationOTPView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            config: config,
            factory: factory,
            otpViewModel: otpViewModel
        )
    }
    
    func consentsView() -> some View {
        
        CreateDraftCollateralLoanApplicationConsentsView<Confirmation, InformerPayload>(
            state: state,
            event: event,
            externalEvent: { externalEvent($0) },
            config: config,
            factory: factory
        )
    }
    
    private func shimmeringView() -> some View {
        
        RoundedRectangle(cornerRadius: config.layouts.cornerRadius)
            .fill(
                LinearGradient(
                    gradient: config.shimmeringGradient,
                    startPoint: .trailing,
                    endPoint: .leading
                )
            )
            .frame(height: config.layouts.shimmeringHeight)
            .shimmering()
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

public extension CreateDraftCollateralLoanApplicationView {
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Application = CreateDraftCollateralLoanApplication
}

extension CreateDraftCollateralLoanApplicationDomain {
 
    public enum ExternalEvent: Equatable {
        
        case showConsent(URL)
        case goToMain
    }
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel{
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationView<Confirmation, InformerPayload>(
            state: .init(application: .preview),
            event: {
                print($0)
            },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Экран подтверждения параметров кредита")
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
}
