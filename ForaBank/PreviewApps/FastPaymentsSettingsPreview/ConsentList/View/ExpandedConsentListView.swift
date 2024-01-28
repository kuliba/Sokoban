//
//  ExpandedConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct ExpandedConsentListView<Icon: View, CollapseButton: View>: View {
    
    let expanded: ConsentListState.UIState.Expanded
    let event: (ConsentListEvent) -> Void
    let icon: () -> Icon
    let collapseButton: () -> CollapseButton
    
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
            "Search Banks",
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
        .animation(.default, value: bank)
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
            .buttonStyle(.borderedProminent)
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
