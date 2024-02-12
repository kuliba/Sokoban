//
//  CollapsedConsentListView.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import SwiftUI

struct CollapsedConsentListView<Icon: View, ExpandButton: View>: View {
    
    let collapsed: ConsentListState.UIState.Collapsed
    let icon: () -> Icon
    let expandButton: () -> ExpandButton
    let namespace: Namespace.ID
    let anchor: UnitPoint
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            icon()
            
            VStack(alignment: .leading, spacing:6) {
                
                expandButton()
                
                if !collapsed.bankNames.isEmpty {
                    
                    Text(collapsed.bankNames.joined(separator: ", "))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .matchedGeometryEffect(
                id: Match.toggle,
                in: namespace,
                properties: .size,
                anchor: anchor
            )
        }
    }
}

struct CollapsedConsentListView_Preview: PreviewProvider {
    
    @Namespace private static var animationNamespace
    
    static var previews: some View {
        
        VStack(spacing: 32, content: previewsGroup)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            collapsedConsentListView(.empty)
            collapsedConsentListView(.one)
            collapsedConsentListView(.two)
            collapsedConsentListView(.preview)
        }
    }
    
    static func collapsedConsentListView(
        _ collapsed: ConsentListState.UIState.Collapsed
    ) -> some View {
        
        CollapsedConsentListView(
            collapsed: collapsed,
            icon: { Image(systemName: "building.columns") },
            expandButton: {
                HStack {
                    
                    Text("Transfer requests")
                    Spacer()
                    Image(systemName: "chevron.up")
                }
                .foregroundColor(.secondary)
                .font(.footnote)
            },
            namespace: animationNamespace,
            anchor: .center
        )
    }
}
