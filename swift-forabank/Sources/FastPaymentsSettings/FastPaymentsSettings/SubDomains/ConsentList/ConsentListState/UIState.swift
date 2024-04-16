//
//  UIState.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Foundation

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
            
            init(bankNames: [String]) {
                
                self.bankNames = bankNames
            }
        }
        
        struct Expanded: Equatable {
            
            var searchText: String
            var banks: [ConsentList.SelectableBank]
            var canApply: Bool
            
            init(
                searchText: String,
                banks: [ConsentList.SelectableBank],
                canApply: Bool
            ) {
                self.searchText = searchText
                self.banks = banks
                self.canApply = canApply
            }
        }
    }
}

private extension ConsentList {
    
    var canApply: Bool {
        
        Set(banks.filter(\.isSelected).map(\.id)) != Set(banks.filter(\.isConsented).map(\.id))
    }
    
    var filteredBanks: [SelectableBank] {
        
        if searchText.isEmpty {
            return banks
        } else {
            return banks.filter {
                
                $0.bank.name.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(by: \.bank.name)
        }
    }
}

extension ConsentList.SelectableBank: Comparable {
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs.isSelected, rhs.isSelected) {
        case (true, false): return true
        case (false, true): return false
        default: return lhs.bank.name < rhs.bank.name
        }
    }
}
