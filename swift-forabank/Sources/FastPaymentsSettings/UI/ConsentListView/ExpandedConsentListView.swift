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
    let config: ExpandedConsentConfig = .preview
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            consentListView()
            
            applyButton()
                .opacity(expanded.canApply ? 1 : 0)
        }
    }
    
    private func consentListView() -> some View {
        
        VStack(spacing: 13) {
            
            header()
            
#warning("replace hardcoded height")
            bankList()
                .frame(maxHeight: 350)
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
        
        HStack(spacing: 16) {
            
            icon()
                .frame(width: 24, height: 24)
            
            VStack(spacing: 4) {
                
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
            
            LazyVStack {
                
                ForEach(expanded.banks) {
                    
                    bankView(
                        bank: $0,
                        isLast: $0.id == expanded.banks.last?.id
                    )
                }
            }
        }
    }
    
    private func bankView(
        bank: ConsentList.SelectableBank,
        isLast: Bool
    ) -> some View {
        
        VStack(spacing: 8) {
            
            Button {
                event(.tapBank(bank.id))
            } label: {
                bankLabel(bank)
            }
            .contentShape(Rectangle())
            
            if !isLast { Divider() }
        }
    }
    
    private func bankLabel(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        HStack(spacing: 16) {
            
            checkmark(isSelected: bank.isSelected)
            
            HStack(spacing: 12) {
                
                bankIcon(bank)
                
                bank.name.text(withConfig: config.bank)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .foregroundColor(bank.isSelected ? .primary : .secondary)
        .animation(.easeInOut(duration: 0.2), value: bank.isSelected)
    }
    
    private func checkmark(isSelected: Bool) -> some View {
        
        ZStack {
            
            Circle()
                .fill(isSelected ? config.checkmark.backgroundColor : .clear)
            
            Circle()
                .stroke(isSelected ? .clear : config.checkmark.borderColor)
            
            config.checkmark.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(isSelected ? 1 : 0)
                .foregroundColor(config.checkmark.color)
                .frame(width: 16, height: 16)
        }
        .frame(width: 24, height: 24)
    }
    
    private func bankIcon(
        _ bank: ConsentList.SelectableBank
    ) -> some View {
        
        Image(systemName: "building.columns")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .frame(width: 32, height: 32)
    }
    
    @ViewBuilder
    private func applyButton() -> some View {
        
        ZStack {
            
            config.apply.backgroundColor
            
            Button(action: { event(.applyConsent) }) {
                
                "Применить".text(withConfig: config.apply.title)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension ConsentList.SelectableBank {
    
    var name: String { bank.name }
}

struct ExpandedConsentListView_Previews: PreviewProvider {
    
    @Namespace private static var animationNamespace
    
    static var previews: some View {
        
        Group {
            
            expandedConsentListView(.consented)
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
            
            ExpandedConsentListView(
                expanded: expanded,
                event: { _ in },
                icon: {
                    
                    Image(systemName: "building.columns")
                        .foregroundColor(.secondary)
                },
                collapseButton: {
                    
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
}
