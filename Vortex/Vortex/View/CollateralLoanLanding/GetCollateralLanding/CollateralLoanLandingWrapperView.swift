//
//  CollateralLoanLandingWrapperView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetShowcaseUI
import RxViewModel
import SwiftUI
import UIPrimitives

struct CollateralLoanLandingWrapperView: View {
    
    @Environment(\.openURL) var openURL

    let binder: GetCollateralLandingDomain.Binder
    let factory: Factory
    let config: GetCollateralLandingConfig
    let goToMain: () -> Void
//    let makeOperationDetailInfoViewModel: MakeOperationDetailInfoViewModel

    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content()
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: { destinationView(destination: $0) { event(.dismiss) }}
                )
                .bottomSheet(
                    sheet: state.navigation?.bottomSheet,
                    dismiss: { binder.flow.event(.dismiss) },
                    content: bottomSheetView
                )
        }
    }
    
    private func content() -> some View {
        
        RxWrapperView(
            model: binder.content,
            makeContentView: makeContentView(state:event:)
        )
    }
    
    private func makeContentView(
        state: GetCollateralLandingDomain.State,
        event: @escaping (GetCollateralLandingDomain.Event) -> Void
    ) -> some View {
        
        Group {
            
            switch state.product {
            case .none:
                Color.clear
                    .loader(isLoading: state.product == nil, color: .clear)
                
            case let .some(product):
                getCollateralLandingView(product, state, event, config)
            }
        }
        .onFirstAppear { event(.load(state.landingID)) }
    }
    
    private func getCollateralLandingView(
        _ product: GetCollateralLandingProduct,
        _ state: GetCollateralLandingDomain.State,
        _ event: @escaping (GetCollateralLandingDomain.Event) -> Void,
        _ config: GetCollateralLandingConfig
    ) -> some View {
        
        GetCollateralLandingView(
            state: state,
            domainEvent: event,
            externalEvent: {
                switch $0 {
                case let .showCaseList(id):
                    binder.flow.event(.select(.showCaseList(id)))
                    
                case let .createDraftApplication(product):
                    let payload = state.payload(product)
                    binder.flow.event(.select(.createDraft(payload)))
                    
                case let .openDocument(link):
                    if let url = URL(string: link) {
                        openURL(url)
                    }
                }
            },
            config: config,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL,
                getPDFDocument: factory.getPDFDocument,
                formatCurrency: factory.formatCurrency
            )
        )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: GetCollateralLandingDomain.Navigation.Destination,
        dissmiss: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case let .createDraft(binder):
            CreateDraftCollateralLoanApplicationWrapperView(
                binder: binder,
                config: .default,
                factory: .init(
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                    makeImageViewWithURL: factory.makeImageViewWithURL,
                    getPDFDocument: factory.getPDFDocument,
                    formatCurrency: factory.formatCurrency
                ),
                goToMain: goToMain
//                makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
            )
            .navigationBarWithBack(title: "Оформление заявки", dismiss: dissmiss)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        bottomSheet: GetCollateralLandingDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .showBottomSheet(type):
            switch type {
            case .periods:
                periodsBottomSheetView
                
            case .collaterals:
                collateralsBottomSheetView
            }
        }
    }
    
    private var periodsBottomSheetView: some View {
        
        GetCollateralLandingBottomSheetView(
            state: binder.content.state,
            event: handlePeriodsDomainEvent(_:),
            config: config.bottomSheet,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL,
                getPDFDocument: factory.getPDFDocument,
                formatCurrency: factory.formatCurrency
            ),
            type: .periods
        )
    }
    
    private var collateralsBottomSheetView: some View {
        
        GetCollateralLandingBottomSheetView(
            state: binder.content.state,
            event: handlePeriodsDomainEvent(_:),
            config: config.bottomSheet,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL,
                getPDFDocument: factory.getPDFDocument,
                formatCurrency: factory.formatCurrency
            ),
            type: .collaterals
        )
    }

    private func handlePeriodsDomainEvent(_ event: GetCollateralLandingDomain.Event) {
        
        binder.content.event(event)
        // Делаем задержку закрытия, чтобы пользователь увидел на шторке выбранный айтем
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [binder] in
            binder.flow.event(.dismiss)
        }
    }
    
    private func handleCollateralsDomainEvent(_ event: GetCollateralLandingDomain.Event) {
        
        binder.content.event(event)
        binder.flow.event(.dismiss)
    }
}
 
extension CollateralLoanLandingWrapperView {
    
    typealias Factory = CollateralLoanLandingFactory
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias Payload = CollateralLandingApplicationSaveConsentsResult
    typealias MakeOperationDetailInfoViewModel = (Payload, @escaping () -> Void) -> OperationDetailInfoViewModel

    public typealias makeImageViewWithMD5Hash = (String) -> UIPrimitives.AsyncImage
    public typealias makeImageViewWithURL = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .createDraft(binder):
            return .createDraft(binder)
            
        case .showBottomSheet:
            return nil
        }
    }
    
    enum Destination {
        
        case createDraft(Domain.Binder)
    }
    
    var bottomSheet: BottomSheet? {
        
            switch self {
            case .createDraft:
                return nil
                
            case let .showBottomSheet(id):
                return .showBottomSheet(id)
            }
    }
    
    enum BottomSheet {
        
        case showBottomSheet(GetCollateralLandingDomain.ExternalEvent.CaseType)
    }
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
}

extension GetCollateralLandingDomain.Navigation.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
        case let .createDraft(binder): return .init(binder)
        }
    }
}

extension GetCollateralLandingDomain.Navigation.BottomSheet: Identifiable, BottomSheetCustomizable {
    
    var id: String {
        
        switch self {
        case let .showBottomSheet(id):
            switch id {
            case .periods:
                return "periods"
                
            case .collaterals:
                return "collaterals"
            }
        }
    }
}

extension GetCollateralLandingDomain {
    
    typealias Payload = CreateDraftCollateralLoanApplication
}
