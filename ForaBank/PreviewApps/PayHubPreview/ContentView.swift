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
        let tabComposer = TabModelComposer(scheduler: .main)
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
                    factory: .init(makeBinderView: makeBinderView)
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
    func makeBinderView(
        binder: TabState.Binder
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
            initialState: .init(),
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
                        makeContent: { makePaymentsTransfersContent(binder.content) },
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
                        makeToolbar: { event in
                            
                            ToolbarItem(placement: .topBarLeading) {
                                
                                Button {
                                    event(.profile)
                                } label: {
                                    
                                    if #available(iOS 14.5, *) {
                                        Label("Profile", systemImage: "person.circle")
                                            .labelStyle(.titleAndIcon)
                                    } else {
                                        HStack {
                                            Image(systemName: "person.circle")
                                            Text("Profile")
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                
                                Button {
                                    event(.qr)
                                } label: {
                                    Image(systemName: "qrcode")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    )
                )
            }
        )
    }
    
    @ViewBuilder
    private func makePaymentsTransfersContent(
        _ content: PaymentsTransfersContentModel
    ) -> some View {
        
        PaymentsTransfersView(
            model: content,
            factory: .init(
                makeCategoryPickerView: makeCategoryPickerView,
                makePayHubView: makePayHubFlowView
            )
        )
    }
    
    private func makeCategoryPickerView(
        _ binder: CategoryPickerSectionBinder
    ) -> some View {
        
        Text("TBD: Category picker")
    }
    
    private func makePayHubFlowView(
        _ binder: PayHubPickerBinder
    ) -> some View {
        
        PayHubPickerFlowStateWrapperView(
            binder: binder,
            factory: .init(makeContent: makePayHubContentWrapper)
        )
    }
    
    private func makePayHubContentWrapper(
        _ content: PayHubPickerContent
    ) -> some View {
        
        PayHubPickerContentWrapperView(
            model: content,
            makeContentView: { state, event in
                
                PayHubPickerContentView(
                    state: state,
                    event: event,
                    config: .preview,
                    itemLabel: { item in
                        
                        PayHubPickerStateItemLabel(item: item, config: .preview)
                    }
                )
            }
        )
    }
}

extension CategoryPickerSectionBinder: Loadable {
    
    public func load() {
         
        content.event(.load)
    }
}

extension PayHubPickerBinder: Loadable {
    
    public func load() {
        
        content.event(.load)
    }
}

#Preview {
    ContentView()
}
