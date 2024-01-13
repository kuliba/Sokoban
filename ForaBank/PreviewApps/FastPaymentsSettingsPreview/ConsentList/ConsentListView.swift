//
//  ConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ConsentListView: View {
    
    let state: ConsentListState
    let event: (ConsentListEvent) -> Void
    
    var body: some View {
        
        VStack {
            
            expandCollapseButton()
            
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
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .padding(.horizontal)
        .animation(.easeInOut, value: state)
    }
    
    private func expandCollapseButton() -> some View {
        
        Button {
            event(.toggle)
        } label: {
            HStack {
                
                Text("Request transfers from")
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(chevronRotationAngle))
            }
        }
    }
    
    @ViewBuilder
    private func collapsedView(
        _ collapsed: ConsentListState.Collapsed
    ) -> some View {
        
        if !collapsed.bankNames.isEmpty {
            
            Text(collapsed.bankNames.joined(separator: ", "))
                .font(.headline)
                .multilineTextAlignment(.leading)
        }
    }
    
    private func expandedView(
        _ expanded: ConsentListState.Expanded
    ) -> some View {
        
        VStack {
            
            TextField(
                "Search Banks",
                text: .init(
                    get: { expanded.searchText },
                    set: { event(.search($0)) }
                )
            )
            
            ForEach(expanded.banks, content: bankView)
        }
    }
    
    private func bankView(
        _ bank: ConsentListState.Expanded.SelectableBank
    ) -> some View {
        
        Button(bank.name) { event(.tapBank(bank.id)) }
            .foregroundColor(bank.isSelected ? .primary : .secondary)
    }
    
    private var chevronRotationAngle: CGFloat {
        
        switch state {
        case .collapsed, .collapsedError: return 0
        case .expanded, .expandedError:   return 180
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
        
        Group {
            
            VStack(spacing: 16) {
                
                consentListView(.collapsed(.empty))
                consentListView(.collapsed(.preview))
            }
            
            consentListView(.expanded(.preview))
            consentListView(.collapsedError)
            consentListView(.expandedError)
        }
        .padding(.horizontal)
    }
    
    private static func consentListView(
        _ state: ConsentListState
    ) -> some View {
        
        ConsentListView(
            state: state,
            event: { _ in }
        )
    }
}
