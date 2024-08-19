//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    private let model: TabModel
    
    init(
        selected: TabState.Selected = .noLatest
    ) {
        let flowComposer = PaymentsTransfersModelComposer()
        let tabComposer = TabModelComposer(
            makeFlowModel: flowComposer.compose(loadResult:)
        )
        self.model = tabComposer.compose(selected: selected)
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        
        TabStateWrapperView(
            model: model,
            makeContent: { state, event in
                
                TabView(
                    state: state,
                    event: event,
                    factory: .init(makeFlowView: makeTabViewContent)
                )
            }
        )
    }
}

#warning("move to factory")
private typealias ProfileFlowButtonReducer = FlowButtonReducer<DestinationWrapper<ProfileModel>>
private typealias ProfileFlowButtonEffectHandler = FlowButtonEffectHandler<DestinationWrapper<ProfileModel>>

enum DestinationWrapper<Destination>: Identifiable {
    
    case destination(Destination)
    
    var id: ID {
        
        switch self {
        case .destination: return .destination
        }
    }
    
    enum ID: Hashable {
        
        case destination
    }
}

private extension ContentView {
    
    @ViewBuilder
    func makeTabViewContent(
        tabState: TabState.FlowModel
    ) -> some View {
        
#warning("extract Composer and Factory")
        
        let reducer = PaymentsTransfersFlowReducer()
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            microServices: .init(
                makeProfile: { $0(ProfileModel()) },
                makeQR: { $0(QRModel()) }
            )
        )
        let model = PaymentsTransfersFlowModel(
            initialState: .none,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        PaymentsTransfersFlowStateWrapper(
            model: model,
            makeFlowView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: { makePaymentsTransfersContent(tabState) },
                        makeDestinationContent: {
                            
                            switch $0 {
                            case let .profile(profileModel):
                                Text(String(describing: profileModel))
                            }
                        },
                        makeFullScreenContent: {
                            
                            switch $0 {
                            case let .qr(qrModel):
                                VStack(spacing: 32) {
                                    
                                    Text(String(describing: qrModel))
                                    Button("Close") { model.event(.dismiss) }
                                }
                            }
                        },
                        makeProfileButtonLabel: {
                            
                            if #available(iOS 14.5, *) {
                                Label("Profile", systemImage: "person.circle")
                                    .labelStyle(.titleAndIcon)
                            } else {
                                HStack {
                                    Image(systemName: "person.circle")
                                    Text("Profile")
                                }
                            }
                        },
                        makeQRButtonLabel: {
                            
                            Image(systemName: "qrcode")
                        }
                    )
                )
            }
        )
        .toolbar(content: paymentsTransfersToolbar)
    }
    
#warning("move to factory")
    @ToolbarContentBuilder
    private func paymentsTransfersToolbar(
    ) -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading, content: profileButton)
        ToolbarItem(placement: .topBarTrailing, content: qrButton)
    }
    
    @ViewBuilder
    private func profileButton() -> some View {
        
        let reducer = FlowButtonReducer<DestinationWrapper<ProfileModel>>()
        let effectHandler = FlowButtonEffectHandler<DestinationWrapper<ProfileModel>>(
            microServices: .init(
                makeDestination: { $0(.destination(.init())) }
            )
        )
        let model = FlowButtonModel(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        NavigationDestinationFlowButton(
            model: model,
            buttonLabel: {
                
#warning("inject")
                if #available(iOS 14.5, *) {
                    Label("Profile", systemImage: "person.circle")
                        .labelStyle(.titleAndIcon)
                } else {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                }
            },
            destinationContent: {
                
                switch $0 {
                case let .destination(destination):
                    VStack(spacing: 32) {
                        
                        Text(String(describing: destination))
                        Button("Close") { model.event(.dismissDestination) }
                    }
                }
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func qrButton() -> some View {
        
        let reducer = FlowButtonReducer<DestinationWrapper<QRModel>>()
        let effectHandler = FlowButtonEffectHandler<DestinationWrapper<QRModel>>(
            microServices: .init(
                makeDestination: { $0(.destination(.init())) }
            )
        )
        let model = FlowButtonModel(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        FullScreenCoverFlowButton(
            model: model,
            buttonLabel: {
                
#warning("inject")
                Image(systemName: "qrcode")
            },
            destinationContent: {
                
                switch $0 {
                case let .destination(destination):
                    VStack(spacing: 32) {
                        
                        Text(String(describing: destination))
                        Button("Close") { model.event(.dismissDestination) }
                    }
                }
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func makePaymentsTransfersContent(
        _ model: TabState.FlowModel
    ) -> some View {
        
        PaymentsTransfersView(
            model: model,
            factory: .init(makePayHubView: makePayHubFlowView)
        )
    }
    
    private func makePayHubFlowView(
        _ binder: PayHubBinder
    ) -> some View {
        
        PayHubFlowStateWrapperView(
            binder: binder,
            factory: .init(makeContent: makePayHubContentWrapper)
        )
    }
    
    private func makePayHubContentWrapper(
        _ content: PayHubContent
    ) -> some View {
        
        PayHubContentWrapperView(
            model: content,
            makeContentView: { state, event in
                
                PayHubContentView(
                    state: state,
                    event: event,
                    config: .preview,
                    itemLabel: { item in
                        
                        UIItemLabel(item: item, config: .preview)
                    }
                )
            }
        )
    }
}

#Preview {
    ContentView()
}
