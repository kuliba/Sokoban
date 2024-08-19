//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import PayHub
import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        
        TabStateWrapperView(
            model: .init(),
            makeContent: { state, event in
                
                TabView(
                    state: state,
                    event: event,
                    factory: .init(makeContent: makeTabViewContent)
                )
            }
        )
    }
}

private extension ContentView {
    
    @ViewBuilder
    func makeTabViewContent(
        tabState: TabState
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
            makeContent: {
        
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: { makeContent(tabState) },
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
    }
    
    @ViewBuilder
    func makeContent(
        _ tabState: TabState
    ) -> some View {
        
        let composer = PaymentsTransfersModelComposer()
        let model = composer.compose(loadResult: tabState.loadResult)
        
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

private extension TabState {
    
    var loadResult: PayHubEffectHandler.MicroServices.LoadResult {
        
        switch self {
        case .noLatest:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .noCategories:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .noBoth:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .okEmpty:
            return .success([])
            
        case .ok:
            return .success(.preview)
        }
    }
}

extension Array where Element == Latest {
    
    static let preview: Self = [
        .init(id: UUID().uuidString),
        .init(id: UUID().uuidString),
    ]
}

#Preview {
    ContentView()
}
