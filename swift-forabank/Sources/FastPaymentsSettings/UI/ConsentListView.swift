//
//  ConsentListView.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

enum Match {
    
    case toggle
}

struct ConsentListView: View {
    
    let state: ConsentListState.UIState
    let event: (ConsentListEvent) -> Void
    
    @Namespace private var animationNamespace
    private let anchor: UnitPoint = .top

    var body: some View {
        
        Group {
            
            switch state {
            case let .collapsed(collapsed):
                collapsedView(collapsed)
                
            case let .expanded(expanded):
                expandedView(expanded)
                
            case .collapsedError:
                EmptyView()
                
            case .expandedError:
                expandedErrorView()
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: chevronRotationAngle)
    }
    
    private func toggleButton() -> some View {
        
        Button(action: toggle) {
            
            HStack {
                
                Text("Запросы на переводы из банков")
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(chevronRotationAngle))
            }
        }
        .foregroundColor(.secondary)
        .font(.subheadline)
    }
    
    private func toggle() {
        
        event(.toggle)
    }
    
    private var chevronRotationAngle: CGFloat {
        
        switch state {
        case .collapsed, .collapsedError: return 0
        case .expanded, .expandedError:   return 180
        }
    }
    
#warning("replace with actual")
    private func icon() -> some View {
        
        Image(systemName: "building.columns")
            .imageScale(.large)
    }
    
    @ViewBuilder
    private func collapsedView(
        _ collapsed: ConsentListState.UIState.Collapsed
    ) -> some View {
        
        CollapsedConsentListView(
            collapsed: collapsed,
            icon: icon,
            expandButton: toggleButton, 
            namespace: animationNamespace,
            anchor: anchor
        )
    }
    
    private func expandedView(
        _ expanded: ConsentListState.UIState.Expanded
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            ExpandedConsentListView(
                expanded: expanded,
                event: event,
                icon: icon,
                collapseButton: toggleButton,
                namespace: animationNamespace,
                anchor: anchor
            )
        }
    }
    
    private func expandedErrorView() -> some View {
        
        VStack {
            
            Image(systemName: "magnifyingglass.circle.fill")
                .imageScale(.large)
                .font(.largeTitle)
                .padding(4)
            
            Text("Что-то пошло не так.\nПопробуйте позже.")
        }
        .foregroundColor(.secondary)
    }
}

struct ConsentListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(content: previewsGroup)
            .previewDisplayName("all")
        
        previewsGroup()
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            VStack(spacing: 16) {
                
                consentListView(.collapsed(.empty))
                consentListView(.collapsed(.one))
                consentListView(.collapsed(.two))
                consentListView(.collapsed(.preview))
            }
            .previewDisplayName("Collapsed")
            
            consentListView(.expanded(.preview))
            consentListView(.collapsedError)
            consentListView(.expandedError)
        }
        .padding(.horizontal)
    }
    
    private static func consentListView(
        _ state: ConsentListState.UIState
    ) -> some View {
        
        ConsentListView(
            state: state,
            event: { _ in }
        )
    }
}
