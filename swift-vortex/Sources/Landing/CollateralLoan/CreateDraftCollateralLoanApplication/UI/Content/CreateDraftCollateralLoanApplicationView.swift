//
//  CreateDraftCollateralLoanApplicationView.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Combine
import OTPInputComponent
import SwiftUI
import UIPrimitives

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
        .alert(
            item: backendFailure,
            content: alert(externalEvent: externalEvent)
        )
        .safeAreaInset(edge: .bottom, content: buttonView)
    }
    
    private func applicationForm() -> some View {
        
        VStack {
            
            Group {
                headerView()
                amountView()
                periodView()
                percentView()
                cityView()
            }
            
            confirmationView()
        }
    }
}
    
extension CreateDraftCollateralLoanApplicationView {

    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue: CGFloat { .zero }
        static func reduce(value: inout Value, nextValue: () -> Value) {

            value += nextValue()
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
                
                if state.stage == .confirm {
                 
                    state.confirmation.map { confirmView(otpViewModel: $0) }
                }
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
    
    func alert(
        externalEvent: @escaping (Domain.ExternalEvent) -> Void
    ) -> (AlertFailure) -> Alert {
        
        { alert in

            return .init(
                with: .init(
                    title: "Ошибка",
                    message: alert.message,
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        event: .goToMain
                    )
                ),
                event: externalEvent
            )
        }
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    var backendFailure: AlertFailure? {
        
        guard case let .alert(message) = state.failure?.kind
        else { return nil }
        
        return .init(message: message)
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
            state: .init(application: .preview, formatCurrency: { _ in "" }),
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
