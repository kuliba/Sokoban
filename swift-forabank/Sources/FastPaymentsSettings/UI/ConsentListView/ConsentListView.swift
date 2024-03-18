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
    let config: ConsentListConfig
    
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
                HStack(spacing: 16) {
                    icon()
                    toggleButton()
                }
                .padding(.vertical, 6)
                
            case .expandedError:
                expandedErrorView()
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: chevronRotationAngle)
    }
    
    private func icon() -> some View {
        
        config.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
    
    @ViewBuilder
    private func collapsedView(
        _ collapsed: ConsentListState.UIState.Collapsed
    ) -> some View {
        
        CollapsedConsentListView(
            collapsed: collapsed,
            config: config.collapsedBankList,
            icon: icon,
            expandButton: toggleButton,
            namespace: animationNamespace,
            anchor: anchor
        )
    }
    
    private func expandedView(
        _ expanded: ConsentListState.UIState.Expanded
    ) -> some View {
        
        ExpandedConsentListView(
            expanded: expanded,
            event: event,
            icon: icon,
            collapseButton: toggleButton,
            namespace: animationNamespace,
            anchor: anchor,
            config: config.expandedConsent
        )
    }
    
    private func toggleButton() -> some View {
        
        ConsentListToggleButton(
            chevronRotationAngle: chevronRotationAngle,
            action: { event(.toggle) },
            config: config.chevron
        )
    }
    
    private var chevronRotationAngle: CGFloat {
        
        switch state {
        case .collapsed, .collapsedError: return 0
        case .expanded, .expandedError:   return 180
        }
    }
    
    private func expandedErrorView() -> some View {
        
        VStack(spacing: 12) {
            
            HStack(spacing: 16) {
                
                icon()
                toggleButton()
            }
            
            ZStack {
                
                config.errorIcon.backgroundColor
                    .clipShape(Circle())
                
                config.errorIcon.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .frame(width: 40, height: 40)
            
            "Что-то пошло не так.\nПопробуйте позже.".text(withConfig: config.title)
        }
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
            
            consentListView(.collapsedError)
                .previewDisplayName("Error Collapsed")
            
            consentListView(.expandedError)
                .previewDisplayName("Error Expanded")
            
            VStack(spacing: 16) {
                
                consentListView(.collapsed(.empty))
                consentListView(.collapsed(.one))
                consentListView(.collapsed(.two))
                consentListView(.collapsed(.preview))
            }
            .previewDisplayName("Collapsed")
            
            consentListView(.expanded(.preview()))
                .previewDisplayName("Expanded")
            consentListView(.expanded(.many()))
                .previewDisplayName("Expanded many")
            
            consentListView(.expanded(.apply))
                .previewDisplayName("Apply")
            
#warning("extract to preview content")
            let searchMatch = ConsentListState.success(
                .init(
                    .preview,
                    consent: [],
                    mode: .expanded,
                    searchText: "бан"
                ))
            consentListView(searchMatch.uiState)
                .previewDisplayName("Search: match")
            
            let searchNoMatch = ConsentListState.success(
                .init(
                    .preview,
                    consent: [],
                    mode: .expanded,
                    searchText: "мур"
                ))
            consentListView(searchNoMatch.uiState)
                .previewDisplayName("Search: no match")
                .border(.red)
        }
        .padding(.horizontal)
    }
    
    private static func consentListView(
        _ state: ConsentListState.UIState
    ) -> some View {
        
        ConsentListView(
            state: state,
            event: { _ in },
            config: .preview
        )
    }
}
