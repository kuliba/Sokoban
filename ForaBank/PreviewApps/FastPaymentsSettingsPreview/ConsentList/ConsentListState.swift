//
//  ConsentListState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListState: Equatable {
    
    case consentList(ConsentList)
    case failure(Failure)
}

extension ConsentListState {
    
    struct ConsentList: Equatable {
        
        var banks: [SelectableBank]
        let consent: Set<Bank.ID>
        var mode: Mode
        var searchText: String
        
        var canApply: Bool {
            
            Set(banks.filter(\.isSelected).map(\.id)) != consent
        }
        
        enum Mode: Equatable {
            
            case collapsed, expanded
            
            mutating func toggle() {
                
                switch self {
                case .collapsed:
                    self = .expanded
                    
                case .expanded:
                    self = .collapsed
                }
            }
        }
        
        struct SelectableBank: Equatable, Identifiable {
            
            let bank: Bank
            var isSelected: Bool
            
            var id: Bank.ID { bank.id }
        }
    }
    
    enum Failure {
        
        case collapsedError
        case expandedError
        
        func toggled() -> Self {
            
            switch self {
            case .collapsedError:
                return .expandedError
                
            case .expandedError:
                return .collapsedError
            }
        }
    }
}

#warning("move to View")
extension ConsentListState.ConsentList.SelectableBank {
    
    var name: String { bank.name }
}

extension ConsentListState.ConsentList {
    
    var selectedBanks: [Bank] {
        
        banks.filter(\.isSelected).map(\.bank)
    }
    
    var selectedBankNames: [String] {
        
        selectedBanks.map(\.name)
    }
}

extension ConsentListState {
    
    var uiState: UIState {
        
        switch self {
        case let .consentList(consentList):
            switch consentList.mode {
            case .collapsed:
                return .collapsed(.init(
                    bankNames: consentList.selectedBankNames
                ))
                
            case .expanded:
                return .expanded(.init(
                    searchText: consentList.searchText,
                    banks: consentList.banks,
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
            var banks: [ConsentListState.ConsentList.SelectableBank]
            var canApply: Bool
        }
    }
}
