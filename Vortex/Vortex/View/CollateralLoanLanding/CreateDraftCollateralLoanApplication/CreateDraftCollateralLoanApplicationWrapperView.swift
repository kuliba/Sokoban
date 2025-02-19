//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetConsentsBackend
import InputComponent
import OTPInputComponent
import RemoteServices
import RxViewModel
import SwiftUI
import ButtonWithSheet

struct CreateDraftCollateralLoanApplicationWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: Domain.Binder
    let config: Config
    let factory: Factory
    let viewModelFactory: ViewModelFactory
    let goToMain: () -> Void
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in

            content()
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
    
    private func content() -> some View {

        RxWrapperView(
            model: binder.content,
            makeContentView: makeContentView(state:event:)
        )
    }
    
    @ViewBuilder
    private func makeContentView(
        state: State<Confirmation, InformerData>,
        event: @escaping (Event<Confirmation, InformerData>) -> Void
    ) -> some View {
        
        content(state: state, event: event)
            .frame(maxHeight: .infinity)
    }

    private func content(
        state: State<Confirmation, InformerData>,
        event: @escaping (Event<Confirmation, InformerData>) -> Void
    ) -> some View {

        CreateDraftCollateralLoanApplicationView(
            state: state,
            event: event,
            externalEvent: handleExternalEvent(events:),
            config: .default,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL,
                getPDFDocument: factory.getPDFDocument
            )
        )
        .if(state.stage == .confirm) {
        
            $0.navigationBarBackButtonHidden(true)
              .navigationBarItems(leading: buttonBack(event: event))
        }
    }
    
    func buttonBack(event: @escaping (Event<TimedOTPInputViewModel, InformerData>) -> Void) -> some View {
        
        Button(action: { event(.back) }) {
            
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
            
        case .goToMain:
            goToMain()
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
            CreateDraftCollateralLoanApplicationCompleteView(
                state: .completed,
                action: goToMain,
                makeIconView: factory.makeImageViewWithMD5Hash,
                pdfDocumentButton: makePDFDocumentButton(
                    payload: saveConsentsResult.payload,
                    getPDFDocument: factory.getPDFDocument
                ),
                detailsButton: makeDetailButton(payload: saveConsentsResult)
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
    
    private func makePDFDocumentButton(
        payload: RemoteServices.RequestFactory.GetConsentsPayload,
        getPDFDocument: @escaping PDFDocumentButton.GetPDFDocument
    ) -> PDFDocumentButton {
        
        .init(getDocument: { getPDFDocument(payload, $0) })
    }
    
    func makeDetailButton(payload: CollateralLandingApplicationSaveConsentsResult) -> CollateralLoanLandingDetailsButton {
        
            .init(
                viewModel: viewModelFactory.makeOperationDetailInfoViewModel(
                    payload: payload,
                    dismiss: goToMain
                ),
                payload: payload
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
        .init(getDocument: { _ in })
    }
}

extension CreateDraftCollateralLoanApplicationWrapperView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias ViewModelFactory = CollateralLoanLandingViewModelFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State
    typealias Event = Domain.Event
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias MakeAnywayElementModelMapper = () -> AnywayElementModelMapper
    typealias Confirmation = CreateDraftCollateralLoanApplicationDomain.Confirmation
}

// MARK: UI mapping

extension CreateDraftCollateralLoanApplicationDomain.Navigation {

    var alert: Alert? {
        
        switch self {
        case let .failure(kind):
            switch kind {
            case let .timeout(informerPayload):
                return .failure(informerPayload.message)

            case let .error(message):
                return .failure(message)
            }
        case .saveConsents(_):
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
            
        case let .saveConsents(result):
            return .success(result)
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
