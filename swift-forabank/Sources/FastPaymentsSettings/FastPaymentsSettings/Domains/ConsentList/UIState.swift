//
//  UIState.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Foundation

public extension ConsentListState {
    
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
        
        public struct Collapsed: Equatable {
            
            public let bankNames: [String]
            
            public init(bankNames: [String]) {
                
                self.bankNames = bankNames
            }
        }
        
        public struct Expanded: Equatable {
            
            public var searchText: String
            public var banks: [ConsentList.SelectableBank]
            public var canApply: Bool
            
            public init(
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
        
        Set(banks.filter(\.isSelected).map(\.id)) != consent
    }
    
    var filteredBanks: [SelectableBank] {
        
        if searchText.isEmpty {
            return banks.sorted()
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
