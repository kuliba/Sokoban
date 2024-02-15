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
    let config: ExpandedConsentConfig
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            consentListView()
            
            applyButton()
                .opacity(expanded.canApply ? 1 : 0)
                .animation(.default, value: expanded.canApply)
                .offset(y: EdgeInsets.default.bottom)
        }
    }
    
    private func consentListView() -> some View {
        
        VStack(spacing: 13) {
            
            header()
            
#warning("replace hardcoded height")
            banks()
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
    
    @ViewBuilder
    private func banks() -> some View {
        
        ZStack {
            noMatch()
                .opacity(expanded.banks.isEmpty ? 1 : 0)
                .frame(height: expanded.banks.isEmpty ? nil : 0)
            // .animation(.default, value: expanded.banks.isEmpty)
            
            bankList()
                .opacity(expanded.banks.isEmpty ? 0 : 1)
        }
    }
    
    private func noMatch() -> some View {
        
        VStack(spacing: 8) {
            
            ZStack {
                
                config.noMatch.image.backgroundColor
                    .clipShape(Circle())
                
                config.noMatch.image.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
            
            "Не удалось найти банк".text(withConfig: config.noMatch.title)
        }
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
                
                Color.clear
                    .frame(height: expanded.canApply ? 48 : 0)
                    .animation(.default, value: expanded.canApply)
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
        
        HStack(spacing: 12) {
            
            checkmark(isSelected: bank.isSelected)
            
            bankIcon(bank)
            
            bank.name.text(withConfig: config.bank)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(width: 32, height: 32)
    }
    
    private func bankIcon(
        _ selectableBank: ConsentList.SelectableBank
    ) -> some View {
        
        selectableBank.bank.image
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
            expandedConsentListView(.preview())
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
                anchor: .center,
                config: .preview
            )
        }
    }
}
