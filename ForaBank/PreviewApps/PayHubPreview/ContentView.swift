//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    var body: some View {
        
        TabWrapperView(
            model: .init(), 
            factory: .init(
                makeContent: { tabState in
                    
                    let composer = PaymentsTransfersModelComposer()
                    let model = composer.compose(loadResult: tabState.loadResult)
                    
                    return PaymentsTransfersView(
                        model: model,
                        factory: .init(
                            makePayHubView: { binder in
                            
                                PayHubFlowStateWrapperView(
                                    binder: binder,
                                    factory: .init(
                                        makeContent: { content in
                                        
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
                                    )
                                )
                                .onFirstAppear { binder.content.event(.load) }
                            }
                        )
                    )
                }
            )
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
