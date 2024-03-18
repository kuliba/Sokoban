//
//  CollapsedConsentListView.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import SwiftUI
import UIPrimitives

struct CollapsedConsentListView<Icon: View, ExpandButton: View>: View {
    
    let collapsed: ConsentListState.UIState.Collapsed
    let config: TextConfig
    let icon: () -> Icon
    let expandButton: () -> ExpandButton
    let namespace: Namespace.ID
    let anchor: UnitPoint
    
    var body: some View {
        
        HStack(alignment: alignment, spacing: 16) {
            
            icon()
                .padding(.top, topPadding)
            
            VStack(alignment: .leading, spacing:6) {
                
                expandButton()
                
                if !collapsed.bankNames.isEmpty {
                    
                    collapsed.bankNames.joined(separator: ", ").text(withConfig: config)
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
    
    private var alignment: VerticalAlignment {
        
        collapsed.bankNames.isEmpty ? .center : .top
    }
    
    private var topPadding: CGFloat {
        
        collapsed.bankNames.isEmpty ? .zero : 11
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
        .border(.red)
    }
    
    static func collapsedConsentListView(
        _ collapsed: ConsentListState.UIState.Collapsed
    ) -> some View {
        
        CollapsedConsentListView(
            collapsed: collapsed, 
            config: .init(
                textFont: .headline, 
                textColor: .green
            ),
            icon: {
                
                Image(systemName: "building.columns")
                    .foregroundColor(.secondary)
            },
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
