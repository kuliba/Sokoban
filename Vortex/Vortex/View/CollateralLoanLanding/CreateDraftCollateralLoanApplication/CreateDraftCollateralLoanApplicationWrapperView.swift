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
    let goToMain: () -> Void
    
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
            .fullScreenCover(
                cover: state.navigation?.cover,
                content: fullScreenCoverView
            )
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
                dismissButton: .default(Text("ОK")) { goToMain() }
            )
        }
    }
    
    @ViewBuilder
    private func fullScreenCoverView(
        cover: CreateDraftCollateralLoanApplicationDomain.Navigation.Cover
    ) -> some View {
        
        switch cover {
        case let .success(saveConsentsResult):
            PaymentCompleteView(
                state: makePaymentCompleteState(from: saveConsentsResult),
                goToMain: goToMain,
                repeat: {},
                factory: makePaymentCompleteViewFactory(),
                config: .collateralLoanLanding
            )
            
        case .failure:
            PaymentCompleteView(
                state: .rejected,
                goToMain: goToMain,
                repeat: {},
                factory: makePaymentCompleteViewFactory(),
                config: .collateralLoanLanding
            )
        }
    }
    
    private func makePaymentCompleteState(
        from saveConsentsResult: CollateralLandingApplicationSaveConsentsResult
    ) -> PaymentCompleteState {
        
        .init(
            formattedAmount: saveConsentsResult.formattedAmount(),
            merchantIcon: nil,
            result: .success(makeReport(from: saveConsentsResult))
        )
    }
    
    private func makeReport(
        from saveConsentsResult: CollateralLandingApplicationSaveConsentsResult
    ) -> PaymentCompleteState.Report {
        
        .init(
            detailID: 123,
            details: operationDetails(from: saveConsentsResult),
            operationDetail: nil,
            printFormType: "",
            status: .completed
        )
    }
    
    private func makePaymentCompleteViewFactory() -> PaymentCompleteViewFactory {
        
        return .init(
            makeDetailButton: { .init(details: $0) },
            makeDocumentButton: makeTransactionDocumentButton,
            makeIconView: { factory.makeImageViewWithMD5Hash($0 ?? "") },
            makeTemplateButton: { nil },
            makeTemplateButtonWrapperView: { _ in makeTemplateButtonWrapperView() }
        )
    }
    
    private func makeTemplateButtonWrapperView() -> TemplateButtonStateWrapperView {
        
        .init(viewModel: .init(model: .emptyMock, operation: nil, operationDetail: .stub()))
    }
    
    private func makeTransactionDocumentButton(
        documentID: DocumentID,
        printFormType: RequestFactory.PrintFormType
    ) -> TransactionDocumentButton {
        .init(getDocument: { _ in }) // TODO: Load PDFDocument via getConsents request
    }
    
    // TODO: realize map
    private func operationDetails(
        from saveConsentsResult: CollateralLandingApplicationSaveConsentsResult
    ) -> TransactionDetailButton.Details {

        .init(
            logo: nil,
            cells: [
                .init(title: "Деталь 1"),
                .init(title: "Деталь 2"),
                .init(title: "Деталь 3")
            ]
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
            return .failure
            
        case let .success(success):
            return .success(success)
        }
    }
    
    enum Cover {
        case success(CollateralLandingApplicationSaveConsentsResult)
        case failure
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Cover: Identifiable {
    
    var id: String {
        
        switch self {
        case .failure:
            return "failure"
        case .success:
            return "success"
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
