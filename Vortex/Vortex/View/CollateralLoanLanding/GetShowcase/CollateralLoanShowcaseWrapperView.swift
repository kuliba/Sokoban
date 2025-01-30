//
//  CollateralLoanShowcaseWrapperView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 25.12.2024.
//

import BottomSheetComponent
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetShowcaseUI
import RxViewModel
import SwiftUI
import UIPrimitives

struct CollateralLoanShowcaseWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: GetShowcaseDomain.Binder
    let factory: Factory

    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RxWrapperView(
                model: binder.content,
                makeContentView: content(state:event:)
            )
            .navigationDestination(
                destination: state.navigation,
                content: destinationView
            )
        }
    }
    
    private func content(
        state: GetShowcaseDomain.State,
        event: @escaping (GetShowcaseDomain.Event) -> Void
    ) -> some View {
        
        Group {
            
            switch state.showcase {
            case .none:
                SpinnerView(viewModel: .init())
                
            case let .some(showcase):
                getShowcaseView(showcase)
            }
        }
        .onFirstAppear { event(.load) }
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
            CollateralLoanLandingWrapperView(
                binder: landing,
                factory: .init(
                    makeImageViewByMD5Hash: factory.makeImageViewByMD5Hash,
                    makeImageViewByURL: factory.makeImageViewByURL,
                    makeOTPView: factory.makeOTPView
                )
            )
        }
    }
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}

extension GetShowcaseDomain.Navigation: Identifiable {

    var id: String {
        
        switch self {
        case let .landing(id, _): return id
        }
    }
}
