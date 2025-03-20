//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import ButtonWithSheet
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetConsentsBackend
import CollateralLoanLandingGetShowcaseUI
import InputComponent
import OTPInputComponent
import PaymentCompletionUI
import PDFKit
import RemoteServices
import RxViewModel
import SwiftUI

enum DocumentButtonState {
    
    case pending
    case completed(PDFDocument)
    case loading
    case failure(Failure)
    
    enum Failure: Equatable {
        
        case informer(InformerData)
        case alert(String)
        case offline
    }
}

struct CreateDraftCollateralLoanApplicationWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    @SwiftUI.State var documentButtonState: DocumentButtonState = .pending
    
    let binder: Domain.Binder
    let config: Config
    let factory: Factory
    let goToPlaces: () -> Void
    let goToMain: () -> Void
    let makeOperationDetailInfoViewModel: ViewComponents.MakeOperationDetailInfoViewModel
    let getPDFDocument: GetPDFDocument
    
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

        ZStack(alignment: .top) {
            
            binder.flow.state.navigation?.informer.map(informerView)
                .zIndex(1)
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
        }
    }
    
    @ViewBuilder
    private func makeContentView(
        state: State,
        event: @escaping (Event) -> Void
    ) -> some View {
        
        content(state: state, event: event)
            .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func content(
        state: State,
        event: @escaping (Event) -> Void
    ) -> some View {

        if state.isLoading {
            
            Color.clear
                .loader(isLoading: state.isLoading, color: .clear)
        } else {
            
            CreateDraftCollateralLoanApplicationView(
                state: state,
                event: event,
                externalEvent: handleExternalEvent(events:),
                config: .default,
                factory: factory
            )
        }
    }
        
    func getDocumentButton(
        payload: RemoteServices.RequestFactory.GetConsentsPayload
    ) -> DocumentButton {
       
        return .init(
            state: $documentButtonState,
            goToPlaces: goToPlaces,
            goToMain: goToMain
        ) {
       
            getPDFDocument(payload) {
                
                switch $0 {
                case let .success(pdfDocument):
                    documentButtonState = .completed(pdfDocument)
                    
                case let .failure(failure):
                    switch failure.kind {
                    case let .alert(message):
                        documentButtonState = .failure(.alert(message))

                    case let .informer(informerData):
                        documentButtonState = .failure(.informer(informerData))

                    case .offline:
                        documentButtonState = .failure(.offline)

                    case .failureResultScreen, .incorrectOTP, .serviceFailure:
                        break
                    }
                }
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
                state: PaymentCompletion.Status.completed,
                action: goToMain,
                makeIconView: factory.makeImageViewWithMD5Hash,
                documentButton: getDocumentButton(payload: saveConsentsResult.payload),
                detailsButton: makeDetailButton(payload: saveConsentsResult)
            )
            
        case .failureComplete:
            PaymentCompleteView(
                state: .init(
                    formattedAmount: "",
                    merchantIcon: nil,
                    result: .failure(.init(hasExpired: false))
                ),
                goToMain: goToMain,
                repeat: {
                },
                factory: makePaymentCompleteViewFactory(),
                config: .collateralLoanLanding
            )
        }
    }
    
    func makeDetailButton(
        payload: CollateralLandingApplicationSaveConsentsResult
    ) -> CollateralLoanLandingDetailsButton {
        
        let cells = payload.makeCells(
            config: config.elements.result,
            makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
            formatCurrency: factory.formatCurrency
        )
        
        return .init(makeViewModel: makeOperationDetailInfoViewModel, details: cells)
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
    
    private func informerView(
        _ informerData: InformerData
    ) -> some View {
        
        InformerView(
            viewModel: .init(
                message: informerData.message,
                icon: informerData.icon.image,
                color: informerData.color)
        )
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                binder.flow.event(.navigation(.failure(.none)))
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationWrapperView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.ContentState
    typealias Event = Domain.ContentEvent
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias MakeAnywayElementModelMapper = () -> AnywayElementModelMapper
    typealias Confirmation = CreateDraftCollateralLoanApplicationDomain.Confirmation
    typealias GetPDFDocument = Domain.GetPDFDocument
    
    public typealias Payload = CollateralLandingApplicationSaveConsentsResult
    public typealias MakeOperationDetailInfoViewModel = (Payload) -> OperationDetailInfoViewModel
}

// MARK: UI mapping

extension CreateDraftCollateralLoanApplicationDomain.Navigation {

    var alert: Alert? {
        
        switch self {
        case let .failure(kind):
            switch kind {
            case let .alert(message):
                return .failure(message)
            default:
                return nil
            }
        case .saveConsents:
            return nil
        }
    }

    enum Alert {
        
        case failure(String)
    }

    var cover: Cover? {
        
        switch self {
        case let .failure(kind):
            switch kind {
            case .complete:
                return .failureComplete
            default:
                return nil
            }
            
        case let .saveConsents(result):
            return .success(result)
        }
    }
    
    var informer: CreateDraftCollateralLoanApplicationDomain.InformerPayload? {
        
        guard case let .failure(.informer(informer)) = self
        else { return nil }
        
        return informer
    }

    enum Cover {
        case success(CollateralLandingApplicationSaveConsentsResult)
        case failureComplete
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Cover: Identifiable {
    
    var id: String {
        
        switch self {
        case .failureComplete:
            return "failureComplete"
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
