//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import InputComponent
import OTPInputComponent
import RxViewModel
import SwiftUI

struct CreateDraftCollateralLoanApplicationWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: Domain.Binder
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
            .alert(
                item: state.navigation?.alert,
                content: makeAlert
            )
            .fullScreenCover(cover: state.navigation?.cover, content: fullScreenCoverView)
        }
    }
    
    private func makeContentView(
        state: State,
        event: @escaping (Event) -> Void
    ) -> some View {
        
        ZStack {
            
            if state.isLoading {
                
                SpinnerView(viewModel: .init())
                    .zIndex(1.0)
            }
            content(state: state, event: event)
        }
        .frame(maxHeight: .infinity)
    }

    private func content(
        state: State,
        event: @escaping (Event) -> Void
    ) -> some View {

        CreateDraftCollateralLoanApplicationView(
            state: state,
            event: event,
            externalEvent: handleExternalEvent(events:),
            config: .default,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL
            )
        )
        .if(state.stage == .confirm) {
        
            $0.navigationBarBackButtonHidden(true)
              .navigationBarItems(leading: buttonBack(event: event))
        }
    }
    
    func buttonBack(event: @escaping (Event) -> Void) -> some View {
        
        Button(action: { event(.tappedBack) }) {
            
            HStack {
                Image.ic16ChevronLeft
                    .aspectRatio(contentMode: .fit)
                Text("Оформление заявки")
            }
        }
    }
    
    private func handleExternalEvent(events: Domain.ExternalEvent) {
        
        switch events {
        case let .showConsent(url):
            openURL(url)
        }
    }
    
    private func makeAlert(
        alert: CreateDraftCollateralLoanApplicationDomain.Navigation.Alert
    ) -> SwiftUI.Alert {
        
        switch alert {
            
        case let .failure(failure):
            return .init(
                title: Text("Ошибка"),
                message: Text(failure),
                // TODO: + Action: возврат на гл. экран
                dismissButton: .default(Text("ОK")) { fatalError("Implement return to main view") }
            )
        }
    }
    
    @ViewBuilder
    private func fullScreenCoverView(
        cover: CreateDraftCollateralLoanApplicationDomain.Navigation.Cover
    ) -> some View {
        
        switch cover {
        case let .completed(saveConsentsResult):
            PaymentCompleteView(
                state: makePaymentCompleteState(from: saveConsentsResult),
                goToMain: {},
                repeat: {},
                factory: <#T##Factory#>,
                makeIconView: { factory.makeImageViewWithMD5Hash($0 ?? "") },
                config: .collateralLoanLanding
            )
            //            Text(String(describing: saveConsentsResult))
        }
    }
    
    private func makePaymentCompleteState(
        from saveConsentsResult: CollateralLandingApplicationSaveConsentsResult
    ) -> PaymentCompleteState {
        
        .init(
            formattedAmount: saveConsentsResult.formattedAmount(),
            merchantIcon: <#T##String?#>,
            result: <#T##Result<PaymentCompleteState.Report, PaymentCompleteState.Fraud>#>
        )
    }
}

extension CreateDraftCollateralLoanApplicationWrapperView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State
    typealias Event = Domain.Event
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias MakeAnywayElementModelMapper = () -> AnywayElementModelMapper
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation {
    
    var alert: Alert? {
        
        switch self {
        case let .failure(failure):
            return .failure(failure)
            
        case .success:
            return nil
        }
    }

    enum Alert {
        
        case failure(String)
    }

    var cover: Cover? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(success):
            return .completed(success)
        }
    }
    
    enum Cover {
        case completed(CollateralLandingApplicationSaveConsentsResult)
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Cover: Identifiable {
    
    var id: UInt {
        
        switch self {
        case let .completed(completed):
            return completed.applicationID
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Alert: Identifiable {
    
    var id: String {
        
        switch self {
        case let .failure(failure):
            return failure
        }
    }
}
