//
//  PayHubContentView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct PayHubContentView<ItemLabel>: View
where ItemLabel: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let itemLabel: (Item) -> ItemLabel
    
    private let transition: AnyTransition = .opacity
        .combined(with: .asymmetric(
            insertion: .identity,
            removal: .scale
        ))
    // .combined(with: .asymmetric(
    //     insertion: .move(edge: .trailing),
    //     removal: .move(edge: .leading).combined(with: .scale)
    // ))
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                
                ForEach(state.items, content: itemView)
            }
            .animation(.easeInOut, value: state)
        }
        .frame(height: config.height)
    }
}

extension PayHubContentView {
    
    typealias State = PayHubState
    typealias Event = PayHubEvent
    typealias Config = PayHubContentViewConfig
    typealias Item = PayHubState.Item
}

private extension PayHubContentView {
    
    @ViewBuilder
    func itemView(
        item: Item
    ) -> some View {
        
        let label = itemLabel(item)
            .contentShape(Rectangle())
            .transition(transition(for: item))
        
        switch item {
        case .placeholder:
            label
            
        case let .element(identified):
            Button {
                event(.select(identified.element))
            } label: {
                label.contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    func transition(
        for item: Item
    ) -> AnyTransition {
        
        switch item {
        case .placeholder:
            return transition
            
        case let .element(identified):
            switch identified.element {
            case .exchange:  return .identity
            case .latest:    return transition
            case .templates: return .identity
            }
        }
    }
}

// MARK: - Previews

struct PayHubContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            samples()
            PayHubContentViewDemo()
        }
    }
    
    private static func samples() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 8) {
                
                Group {
                    
                    payHubContentView(.placeholderPreview(count: 0))
                    payHubContentView(.placeholderPreview(count: 1))
                    payHubContentView(.placeholderPreview(count: 2))
                    payHubContentView(.placeholderPreview(count: 5))
                    payHubContentView(.loadedPreview(count: 0))
                    payHubContentView(.loadedPreview(count: 1))
                    payHubContentView(.loadedPreview(count: 2))
                    payHubContentView(.loadedPreview(count: 3))
                    payHubContentView(.loadedPreview(count: 5))
                    payHubContentView(.loadedPreview(count: 10))
                }
                .border(.red.opacity(0.2))
            }
            .padding()
        }
    }
    
    private static func payHubContentView(
        _ state: PayHubState,
        event: @escaping (PayHubEvent) -> Void = { print($0) }
    ) -> some View {
        
        PayHubContentView(
            state: state,
            event: event,
            config: .preview,
            itemLabel: { item in
                
                UIItemLabel(item: item, config: .preview)
            }
        )
    }
    
    private struct PayHubContentViewDemo: View {
        
        @State private var state: PayHubState = .default
        @State private var loadViaReset = false
        
        var body: some View {
            
            ZStack(alignment: .top) {
                
                Toggle("Load via reset", isOn: $loadViaReset)
                    .padding(.horizontal)
                
                ZStack(alignment: .bottom) {
                    
                    VStack(spacing: 32) {
                        
                        VStack(spacing: 8) {
                            
                            Button("Reset") { state = .default }
                            Button("Load 0") { load(.loadedPreview(count: 0)) }
                            Button("Load 1") { load(.loadedPreview(count: 1)) }
                            Button("Load 3") { load(.loadedPreview(count: 3)) }
                            Button("Load 5") { load(.loadedPreview(count: 5)) }
                            Button("Load 10") { load(.loadedPreview(count: 10)) }
                        }
                        
                        payHubContentView(state) {
                            
                            switch $0 {
                            case let .select(select):
                                state.selected = select
                                
                            default:
                                print($0)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    Text("Selected: " + String(describing: state.selected))
                        .foregroundColor(state.selected == nil ? .secondary : .primary)
                        .padding(.horizontal)
                }
            }
        }
        
        private func load(_ state: PayHubState) {
            
            if loadViaReset {
                
                self.state = .default
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    self.state = state
                }
            } else {
                
                self.state = state
            }
        }
        
        private func makeLatests(
            count: Int = .random(in: 0..<20)
        ) -> [Latest] {
            
            (0..<count).map { _ in .init(id: UUID().uuidString) }
        }
    }
}

private extension PayHubState {
    
    static let `default`: Self = .init(
        suffix: [
            .placeholder(.init()), .placeholder(.init()), .placeholder(.init()), .placeholder(.init()),
        ])
    
    static func loadedPreview(count: Int) -> Self {
        
        return .init(
            suffix: (0..<count).map { _ in .element(.init(.latest(.preview()))) }
        )
    }
    
    static func placeholderPreview(count: Int) -> Self {
        
        return .init(
            suffix: (0..<count).map { _ in .placeholder(.init()) }
        )
    }
    
    private init(suffix: [Item]) {
        
        self.init(
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: suffix
        )
    }
}

extension PayHubContentViewConfig {
    
    static let preview: Self = .init(
        height: 96,
        spacing: 4
    )
}
