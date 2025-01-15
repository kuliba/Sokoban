//
//  CollateralLoanShowcaseView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 25.12.2024.
//

import SwiftUI
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import RxViewModel
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
            CollateralLoanLandingView(binder: landing, makeImageView: factory.makeImageView)
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

struct CollateralLoanLandingView: View {
    
    let binder: GetCollateralLandingDomain.Binder
    let makeImageView: MakeImageView

    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
            .navigationDestination(
                destination: state.navigation?.destination,
                content: destinationView
            )
            .bottomSheet(
                sheet: state.navigation?.bottomSheet,
                dismiss: { binder.flow.event(.dismiss) },
                content: bottomSheetView
            )
        }
    }
    
    private func makeContentView(
        state: GetCollateralLandingDomain.State,
        event: @escaping (GetCollateralLandingDomain.Event) -> Void
    ) -> some View {
        
        GetCollateralLandingView(
            state: state,
            domainEvent: event,
            externalEvent: {
                switch $0 {
                case let .showCaseList(id):
                    binder.flow.event(.select(.showCaseList(id)))
                }
            },
            factory: .init(makeImageView: makeImageView)
        )
        .onFirstAppear {
            event(.load(state.landingID))
        }
    }
    
    @ViewBuilder
    private func destinationView(
        destination: GetCollateralLandingDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .createDraftCollateralLoanApplication(id):
            Text(String(describing: id))
        }
    }

    @ViewBuilder
    private func bottomSheetView(
        bottomSheet: GetCollateralLandingDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .showBottomSheet(id):
            Text(String(describing: id))
                .padding(.bottom, 40)
        }
    }
    
    public typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .createDraftCollateralLoanApplication(id):
            return .createDraftCollateralLoanApplication(id)
            
        case .showBottomSheet:
            return nil
        }
    }
    
    enum Destination {
        
        case createDraftCollateralLoanApplication(String)
    }
    
    var bottomSheet: BottomSheet? {
        
            switch self {
            case let .createDraftCollateralLoanApplication(id):
                return nil
                
            case let .showBottomSheet(id):
                return .showBottomSheet(id)
            }
    }
    
    enum BottomSheet {
        
        case showBottomSheet(GetCollateralLandingDomain.ExternalEvent.CaseType)
    }
}

// TODO: Next realize for binder:

//    var id: ObjectIdentifier {
//
//        switch self {
//        case let .createDraftCollateralLoanApplication(binder): return .init(binder)
//        }
//    }

extension GetCollateralLandingDomain.Navigation.Destination: Identifiable {
    
    var id: String {
        
        switch self {
        case let .createDraftCollateralLoanApplication(id): return id
        }
    }
}

extension GetCollateralLandingDomain.Navigation.BottomSheet: Identifiable, BottomSheetCustomizable {
    
    var id: Int {
        
        switch self {
        case let .showBottomSheet(id): return id.hashValue
        }
    }

}

