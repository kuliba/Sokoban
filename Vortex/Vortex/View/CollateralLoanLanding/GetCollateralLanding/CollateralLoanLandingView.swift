//
//  CollateralLoanLandingView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import SwiftUI
import CollateralLoanLandingGetCollateralLandingUI
import RxViewModel
import UIPrimitives

struct CollateralLoanLandingView: View {
    
    let binder: GetCollateralLandingDomain.Binder
    let factory: Factory
    
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
                case let .createDraftApplication(id):
                    binder.flow.event(.select(.createDraftCollateralLoanApplication(id)))
                }
            },
            factory: .init(
                makeImageViewByMD5Hash: factory.makeImageViewByMD5Hash,
                makeImageViewByURL: factory.makeImageViewByURL
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
            switch id {
            case let .periods(periods):
                GetCollateralLandingBottomSheetView(
                    items: periods.map(\.bottomSheetItem),
                    config: factory.config.bottomSheet,
                    makeImageViewByMD5Hash: factory.makeImageViewByMD5Hash
                ) {
                    switch $0 {
                    case .selectMonthPeriod(let termMonth):
                        binder.content.event(.selectMonthPeriod(termMonth))
                        // Делаем задержку закрытия, чтобы пользователь увидел на шторке выбранный айтем
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [binder] in
                            binder.flow.event(.dismiss)
                        }
                    default: break
                    }
                }
            case let .collaterals(collaterals):
                GetCollateralLandingBottomSheetView(
                    items: collaterals.map(\.bottomSheetItem),
                    config: factory.config.bottomSheet,
                    makeImageViewByMD5Hash: factory.makeImageViewByMD5Hash
                ) {
                    switch $0 {
                    case .selectCollateral(let collateral):
                        binder.content.event(.selectCollateral(collateral))
                        print(collateral)
                        binder.flow.event(.dismiss)
                    default: break
                    }
                }
            }
        }
    }
}
 
extension CollateralLoanLandingView {
    
    typealias Factory = GetCollateralLandingFactory

    public typealias MakeImageViewByMD5Hash = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageViewByURL = (String) -> UIPrimitives.AsyncImage
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
    
    var id: String {
        
        switch self {
        case let .createDraftCollateralLoanApplication(id): return id
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
