//
//  CollateralLoanShowcaseView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 25.12.2024.
//

import BottomSheetComponent
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetShowcaseUI
import RxViewModel
import SwiftUI
import UIPrimitives

struct CollateralLoanShowcaseView: View {
    
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
        state: Domain.State,
        event: @escaping (Domain.Event) -> Void
    ) -> some View {
        
        Group {
            
            switch state.showcase {
            case .none:
                SpinnerView(viewModel: .init())
                
            case let .some(showcase):
                CollateralLoanLandingGetShowcaseView(
                    data: showcase,
                    event: {
                        switch $0 {
                        case let .showLanding(landingId):
                            binder.flow.event(.select(.landing(landingId)))
                            
                        case let .showTerms(urlString):
                            if let url = URL(string: urlString) {
                                openURL(url)
                            }
                        }
                    },
                    factory: factory
                )
            }
        }
        .onFirstAppear { event(.load) }
    }
    
    @ViewBuilder
    private func destinationView(
        navigation: Domain.Navigation
    ) -> some View {
        
        switch navigation {
        case let .landing(landingID, landing):
            CollateralLoanLandingView(
                binder: landing,
                factory: .init(
                    makeImageViewByMD5Hash: factory.makeImageViewByMD5Hash,
                    makeImageViewByURL: factory.makeImageViewByURL
                )
            )
        }
    }
    
    typealias Domain = GetShowcaseDomain
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}

extension GetShowcaseDomain.Navigation: Identifiable {

    var id: String {
        
        switch self {
        case let .landing(id, _): return id
        }
    }
}
