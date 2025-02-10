//
//  CollateralLoanLandingWrapperView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import SwiftUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RxViewModel
import UIPrimitives

struct CollateralLoanLandingWrapperView: View {
    
    let binder: GetCollateralLandingDomain.Binder
    let factory: Factory
    let goToMain: () -> Void
    
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

                case let .createDraftApplication(product):
                    let payload = state.payload(product)
                        binder.flow.event(.select(.createDraftCollateralLoanApplication(payload)))
                }
            },
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL
            )
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
        case let .createDraftCollateralLoanApplication(binder):
            CreateDraftCollateralLoanApplicationWrapperView(
                binder: binder,
                config: .default,
                factory: .init(
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                    makeImageViewWithURL: factory.makeImageViewWithURL
                ), 
                goToMain: goToMain
            )
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
            config: factory.config.bottomSheet,
            factory: factory,
            type: .periods
        )
    }
    
    private var collateralsBottomSheetView: some View {
        
        GetCollateralLandingBottomSheetView(
            state: binder.content.state,
            event: handlePeriodsDomainEvent(_:),
            config: factory.config.bottomSheet,
            factory: factory,
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
    
    typealias Factory = GetCollateralLandingFactory
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult

    public typealias makeImageViewWithMD5Hash = (String) -> UIPrimitives.AsyncImage
    public typealias makeImageViewWithURL = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .createDraftCollateralLoanApplication(binder):
            return .createDraftCollateralLoanApplication(binder)
            
        case .showBottomSheet:
            return nil
        }
    }
    
    enum Destination {
        
        case createDraftCollateralLoanApplication(CreateDraftCollateralLoanApplicationDomain.Binder)
    }
    
    var bottomSheet: BottomSheet? {
        
            switch self {
            case .createDraftCollateralLoanApplication:
                return nil
                
            case let .showBottomSheet(id):
                return .showBottomSheet(id)
            }
    }
    
    enum BottomSheet {
        
        case showBottomSheet(GetCollateralLandingDomain.ExternalEvent.CaseType)
    }
}

extension GetCollateralLandingDomain.Navigation.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
        case let .createDraftCollateralLoanApplication(binder): return .init(binder)
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
    
    typealias Payload = CreateDraftCollateralLoanApplicationUIData
}
