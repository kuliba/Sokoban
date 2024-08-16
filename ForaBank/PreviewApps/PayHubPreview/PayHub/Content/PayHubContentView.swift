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
            
            switch state {
            case .none:
                ProgressView()
                
            case let .some(loaded):
                itemsView(loaded.items)
            }
        }
        .frame(height: config.height)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension PayHubContentView {
    
    typealias State = PayHubState
    typealias Event = PayHubEvent
    typealias Config = PayHubContentViewConfig
    typealias Item = PayHubItem<Latest>
}

extension PayHubItem: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .exchange:  return .exchange
        case .latest:    return .latest
        case .templates: return .templates
        }
    }
    
    public enum ID: Hashable {
        
        case exchange, latest, templates
    }
}

private extension PayHubContentView {
    
    func itemsView(
        _ items: [Item]
    ) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                
                ForEach(items, content: itemView)
            }
        }
    }
    
    func itemView(item: Item) -> some View {
        
        Button {
            event(.select(item))
        } label: {
            itemLabel(item)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension PayHubContentViewConfig {
    
    static let preview: Self = .init(
        height: 96,
        spacing: 4
    )
}
