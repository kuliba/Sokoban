//
//  ExpandedConsentListView.swift
//
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ExpandedConsentListView<Icon: View, CollapseButton: View>: View {
    
    let expanded: ConsentListState.UIState.Expanded
    let event: (ConsentListEvent) -> Void
    let icon: () -> Icon
    let collapseButton: () -> CollapseButton
    let namespace: Namespace.ID
    let anchor: UnitPoint
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            consentListView()
            
            applyButton()
                .opacity(expanded.canApply ? 1 : 0)
        }
    }
    
    private func consentListView() -> some View {
        
        VStack {
            
            header()
            
            bankList()
                .matchedGeometryEffect(
                    id: Match.toggle,
                    in: namespace,
                    properties: .size,
                    anchor: anchor,
                    isSource: false
                )
        }
    }
    
    private func header() -> some View {
        
        HStack(alignment: .top) {
            
            icon()
            
            VStack {
                
                collapseButton()
                
                textField()
            }
        }
    }
    
    private func textField() -> some View {
        
        TextField(
            "Поиск по банкам",
            text: .init(
                get: { expanded.searchText },
                set: { event(.search($0)) }
            )
        )
    }
    
    private func bankList() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            ForEach(expanded.banks, content: bankView)
        }
    }
    
    private func bankView(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        Button {
            event(.tapBank(bank.id))
        } label: {
            bankLabel(bank)
        }
        .foregroundColor(bank.isSelected ? .primary : .secondary)
        .contentShape(Rectangle())
    }
    
    private func bankLabel(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        HStack {
            
            Image(systemName: bank.isSelected ? "checkmark" : "circle")
                .frame(width: 32, height: 32)
            
            bankIcon(bank)
            
            Text(bank.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .animation(.easeInOut(duration: 0.2), value: bank.isSelected)
    }
    
    private func bankIcon(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        Image(systemName: "building.columns")
            .imageScale(.large)
    }
    
    @ViewBuilder
    private func applyButton() -> some View {
        
        Button("Применить") { event(.applyConsent) }
            .padding()
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension ConsentList.SelectableBank {
    
    var name: String { bank.name }
}

//struct ExpandedConsentListView_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        Group {
//
//            expandedConsentListView(.preview)
//            expandedConsentListView(.search)
//            expandedConsentListView(.apply)
//        }
//        .padding(.horizontal)
//    }
//
//    private static func expandedConsentListView(
//        _ expanded: ConsentListState.UIState.Expanded
//    ) -> some View {
//
//        ScrollView {
//
//            ExpandedConsentListView(expanded: expanded, event: { _ in })
//                .padding()
//                .background(.regularMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 9))
//        }
//    }
//}
