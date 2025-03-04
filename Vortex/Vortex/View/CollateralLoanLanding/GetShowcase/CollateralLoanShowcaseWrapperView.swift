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
    let config: Config
    let goToMain: () -> Void
    let makeOperationDetailInfoViewModel: MakeOperationDetailInfoViewModel

    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content()
                .alert(
                    item: state.navigation?.alert,
                    content: makeAlert
                )
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: destinationView
                )
        }
    }
    
    private func content() -> some View {
        
        ZStack(alignment: .top) {
            
            binder.flow.state.navigation?.informer.map(informerView)
                .zIndex(1)
            
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
    }
        
    private func getShowcaseView(_ showcase: GetShowcaseDomain.ShowCase) -> some View {
        
        CollateralLoanLandingGetShowcaseView(
            data: showcase,
            event: handleExternalEvent(_:),
            factory: factory
        )
    }
    
    private func handleExternalEvent(_ event: GetShowcaseViewEvent<InformerData>.External) {

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
        destination: GetShowcaseDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .landing(_, landing):
            CollateralLoanLandingWrapperView(
                binder: landing,
                config: .default,
                factory: factory,
                goToMain: goToMain,
                makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
            )
            .navigationBarWithBack(title: "") { binder.flow.event(.dismiss) }
        }
    }
    
    private func makeAlert(
        alert: GetShowcaseDomain.Navigation.Alert
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
    
    private func informerView(
        _ informerData: InformerData
    ) -> InformerView {
        
        .init(
            viewModel: .init(
                message: informerData.message,
                icon: informerData.icon.image,
                color: informerData.color)
        )
    }
}

extension GetShowcaseDomain.Navigation {
    
    var alert: Alert? {
        
        switch self {
        case let .failure(kind):
            switch kind {
            case let .alert(message):
                return .failure(message)
                
            default:
                return nil
            }
            
        case .landing:
            return nil
        }
    }

    var destination: Destination? {
        
        switch self {
        case .landing(let landingID, let binder):
            return .landing(landingID, binder)

        case .failure:
            return nil
        }
    }
    
    var informer: GetShowcaseDomain.InformerPayload? {
        
        guard case let .failure(.informer(informer)) = self
        else { return nil }
        
        return informer
    }

    enum Alert {
        
        case failure(String)
    }
    
    enum Destination {
        
        case landing(String, GetCollateralLandingDomain.Binder)
    }
}

extension GetShowcaseDomain.Navigation: Identifiable {

    var id: String {
        
        switch self {
        case .landing: return "landing"
        case .failure: return "failure"
        }
    }
}

extension GetShowcaseDomain.Navigation.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
            
        case let .landing(_, binder): return .init(binder)
        }
    }
}

extension GetShowcaseDomain.Navigation.Alert: Identifiable {
    
    var id: String {
        
        switch self {
        case let .failure(message):
            return message
        }
    }
}

extension GetShowcaseDomain.Binder {
    
    static let preview = GetShowcaseDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

extension RxViewModel<
    GetShowcaseDomain.State<InformerData>,
    GetShowcaseDomain.Event<InformerData>,
    GetShowcaseDomain.Effect
> {
    
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

extension CollateralLoanLandingFactory {
    
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

extension CollateralLoanShowcaseWrapperView {
 
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Config = GetCollateralLandingConfig
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias Factory = CollateralLoanLandingFactory
    typealias Payload = CollateralLandingApplicationSaveConsentsResult
    typealias MakeOperationDetailInfoViewModel = (Payload) -> OperationDetailInfoViewModel
}
