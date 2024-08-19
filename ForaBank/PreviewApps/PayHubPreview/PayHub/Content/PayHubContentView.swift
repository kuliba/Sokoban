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
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                
                ForEach((state?.latests).uiItems, content: itemView)
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
    typealias Item = UIItem<Latest>
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
                label
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

extension PayHubContentViewConfig {
    
    static let preview: Self = .init(
        height: 96,
        spacing: 4
    )
}
