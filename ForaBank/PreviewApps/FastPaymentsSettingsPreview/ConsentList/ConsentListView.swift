//
//  ConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ConsentListView: View {
    
    let state: ConsentListState.UIState
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
        .font(.subheadline)
    }
    
    private var chevronRotationAngle: CGFloat {
        
        switch state {
        case .collapsed, .collapsedError: return 0
        case .expanded, .expandedError:   return 180
        }
    }
    
    @ViewBuilder
    private func collapsedView(
        _ collapsed: ConsentListState.UIState.Collapsed
    ) -> some View {
        
        if !collapsed.bankNames.isEmpty {
            
            Text(collapsed.bankNames.joined(separator: ", "))
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func expandedView(
        _ expanded: ConsentListState.UIState.Expanded
    ) -> some View {
        
        ExpandedConsentListView(
            expanded: expanded,
            event: event
        )
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

extension ConsentListState {
    
    var uiState: UIState {
        
        switch self {
        case let .success(consentList):
            switch consentList.mode {
            case .collapsed:
                return .collapsed(.init(
                    bankNames: consentList.selectedBankNames
                ))
                
            case .expanded:
                return .expanded(.init(
                    searchText: consentList.searchText,
                    banks: consentList.filteredBanks,
                    canApply: consentList.canApply
                ))
            }
            
        case let .failure(failure):
            switch failure {
            case .collapsedError:
                return .collapsedError
                
            case .expandedError:
                return .expandedError
            }
        }
    }
    
    enum UIState: Equatable {
        
        case collapsed(Collapsed)
        case expanded(Expanded)
        case collapsedError
        case expandedError
        
        struct Collapsed: Equatable {
            
            let bankNames: [String]
        }
        
        struct Expanded: Equatable {
            
            var searchText: String
            var banks: [ConsentList.SelectableBank]
            var canApply: Bool
        }
    }
}

private extension ConsentList {
    
    var canApply: Bool {
        
        Set(banks.filter(\.isSelected).map(\.id)) != consent
    }
    
    var filteredBanks: [SelectableBank] {
        
        if searchText.isEmpty {
            return banks
        } else {
            return banks.filter {
                
                $0.bank.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct ConsentListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
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
