//
//  CollateralLoanShowcaseWrapperView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 25.12.2024.
//

import BottomSheetComponent
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetShowcaseUI
import Combine
import RxViewModel
import SwiftUI
import UIPrimitives

struct CollateralLoanShowcaseWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: GetShowcaseDomain.Binder
    let factory: Factory
    let viewModelFactory: ViewModelFactory
    let goToMain: () -> Void

    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content()
                .navigationDestination(
                    destination: state.navigation,
                    content: destinationView
                )
        }
    }
    
    private func content() -> some View {
        
        RxWrapperView(model: binder.content) { state, event in
            
            Group {
                
                switch state.showcase {
                case .none:
                    Color.clear
                        .loader(isLoading: state.showcase == nil, color: .clear)
                    
                case let .some(showcase):
                    getShowcaseView(showcase)
                }
            }
            .onFirstAppear { event(.load) }
        }
    }
        
    private func getShowcaseView(_ showcase: GetShowcaseDomain.ShowCase) -> some View {
        
        CollateralLoanLandingGetShowcaseView(
            data: showcase,
            event: handleExternalEvent(_:),
            factory: factory
        )
    }
    
    private func handleExternalEvent(_ event: GetShowcaseViewEvent.External) {

        switch event {
        case let .showLanding(landingId):
            binder.flow.event(.select(.landing(landingId)))
            
        case let .showTerms(urlString):
            if let url = URL(string: urlString) {
                openURL(url)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(
        navigation: GetShowcaseDomain.Navigation
    ) -> some View {
        
        switch navigation {
        case let .landing(_, landing):
            // TODO: Remove to factory
            CollateralLoanLandingWrapperView(
                binder: landing,
                factory: .init(
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                    makeImageViewWithURL: factory.makeImageViewWithURL,
                    getPDFDocument: factory.getPDFDocument,
                    formatCurrency: factory.formatCurrency
                ),
                viewModelFactory: viewModelFactory,
                goToMain: goToMain
            )
            .navigationBarWithBack(title: "") { binder.flow.event(.dismiss) }
        }
    }
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
    typealias ViewModelFactory = CollateralLoanLandingViewModelFactory
}

extension GetShowcaseDomain.Navigation: Identifiable {

    var id: ObjectIdentifier {
        
        switch self {
        case let .landing(_, binder): return .init(binder)
        }
    }
}

extension CollateralLoanShowcaseWrapperView {
    
    static let preview = Self(
        binder: .preview,
        factory: .preview,
        viewModelFactory: .preview,
        goToMain: {}
    )
}

extension GetShowcaseDomain.Binder {
    
    static let preview = GetShowcaseDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

extension RxViewModel<GetShowcaseDomain.State, GetShowcaseDomain.Event, GetShowcaseDomain.Effect> {
    
    static let preview = RxViewModel(
        initialState: .init(),
        reduce: { state ,_ in (state, nil) },
        handleEffect: {_,_ in }
    )
}

extension RxViewModel<
    FlowState<GetShowcaseDomain.Navigation>,
    FlowEvent<GetShowcaseDomain.Select, GetShowcaseDomain.Navigation>, FlowEffect<GetShowcaseDomain.Select>
> {
    static let preview = RxViewModel(
        initialState: .init(),
        reduce: { state ,_ in (state, nil) },
        handleEffect: {_,_ in }
    )
}

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: {_ in .preview },
        getPDFDocument: { _,_ in },
        formatCurrency: { _ in "" }
    )
}

extension UIPrimitives.AsyncImage {
    
    static let preview = Self(
        image: .iconPlaceholder,
        publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
