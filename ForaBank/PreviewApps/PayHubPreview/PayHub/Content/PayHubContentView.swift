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
    
    var body: some View {
        
        Group {
            
            if #available(iOS 16.0, *) {
                
                ScrollView(.horizontal, showsIndicators: false, content: itemsView)
                    .scrollDisabled(state == .none)
            } else {
                
                itemsView()
                    .wrapInScrollView(state != .none, .horizontal, showsIndicators: false)
            }
        }
        .frame(height: config.height)
    }
}

extension PayHubContentView {
    
    typealias State = PayHubState
    typealias Event = PayHubEvent
    typealias Config = PayHubContentViewConfig
    typealias Item = UIItem<Latest>
}

private extension PayHubContentView {
    
    func itemsView() -> some View {
        
        HStack(spacing: config.spacing) {
            
            ForEach((state?.latests).uiItems, content: itemView)
                .transition(
                    .opacity.combined(with: .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                )
        }
        .animation(.easeInOut, value: state)
    }
    
    @ViewBuilder
    func itemView(
        item: UIItem<Latest>
    ) -> some View {
        
        let label = itemLabel(item)
        
        switch item {
        case .placeholder:
            label
            
        case let .selectable(selectable):
            Button {
                event(.select(selectable))
            } label: {
                label.contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private extension View {
    
    @ViewBuilder
    func wrapInScrollView(
        _ isWrapped: Bool = true,
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true
    ) -> some View {
        
        if isWrapped {
            ScrollView(axes, showsIndicators: showsIndicators) { self }
        } else {
            GeometryReader { geometry in
                
                self
                    .frame(width: geometry.size.width, alignment: .leading)
                    .clipped()
            }
        }
    }
}

// MARK: - Previews

struct PayHubContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            group()
            PayHubContentViewDemo()
        }
    }
    
    private static func group() -> some View {
        
        VStack(spacing: 8) {
            
            Group {
                
                payHubContentView(.none)
                payHubContentView(.init(latests: []))
                payHubContentView(.init(latests: [.init(id: UUID().uuidString)]))
                payHubContentView(.init(latests: (0..<2).map { _ in .init(id: UUID().uuidString) }))
                payHubContentView(.init(latests: (0..<10).map { _ in .init(id: UUID().uuidString) }))
            }
            .border(.red.opacity(0.2))
        }
        .padding()
    }
    
    private static func payHubContentView(
        _ state: PayHubState
    ) -> some View {
        
        PayHubContentView(
            state: state,
            event: { print($0) },
            config: .preview,
            itemLabel: { item in
                
                UIItemLabel(item: item, config: .preview)
            }
        )
    }
    
    private struct PayHubContentViewDemo: View {
        
        @State private var state: PayHubState = .none
        
        var body: some View {
            
            VStack(spacing: 32) {
                
                Button("Toggle") {
                    
                    state = state == .none ? .init(latests: makeLatests()) : .none
                }
                
                payHubContentView(state)
            }
        }
        
        private func makeLatests(
            count: Int = .random(in: 0..<20)
        ) -> [Latest] {
            
            (0..<count).map { _ in .init(id: UUID().uuidString) }
        }
    }
}

extension PayHubContentViewConfig {
    
    static let preview: Self = .init(
        height: 96,
        spacing: 4
    )
}
