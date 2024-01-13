//
//  ExpandedConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ExpandedConsentListView: View {
    
    let expanded: ConsentListState.UIState.Expanded
    let event: (ConsentListEvent) -> Void
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            VStack {
                
                TextField(
                    "Search Banks",
                    text: .init(
                        get: { expanded.searchText },
                        set: { event(.search($0)) }
                    )
                )
                
                ScrollView(showsIndicators: false) {
                    
                    ForEach(expanded.banks, content: bankView)
                }
            }
            
            applyButton()
                .opacity(expanded.canApply ? 1 : 0)
        }
    }
    
    private func bankView(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        Button(bank.name) { event(.tapBank(bank.id)) }
            .foregroundColor(bank.isSelected ? .primary : .secondary)
    }
    
    @ViewBuilder
    private func applyButton() -> some View {
        
        Button("Apply") { event(.apply) }
            .buttonStyle(.borderedProminent)
    }
}

private extension ConsentList.SelectableBank {
    
    var name: String { bank.name }
}

struct ExpandedConsentListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            expandedConsentListView(.preview)
            expandedConsentListView(.search)
            expandedConsentListView(.apply)
        }
        .padding(.horizontal)
    }
    
    private static func expandedConsentListView(
        _ expanded: ConsentListState.UIState.Expanded
    ) -> some View {
        
        ScrollView {
            
            ExpandedConsentListView(expanded: expanded, event: { _ in })
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }
    }
}
