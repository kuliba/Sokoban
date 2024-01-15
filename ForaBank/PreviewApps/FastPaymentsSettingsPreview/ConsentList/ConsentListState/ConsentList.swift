//
//  ConsentList.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

struct ConsentList: Equatable {
    
    var banks: [SelectableBank]
    var consent: Consent
    var mode: Mode
    var searchText: String
    var status: Status?
    
    struct SelectableBank: Equatable, Identifiable {
        
        let bank: Bank
        var isSelected: Bool
        
        var id: Bank.ID { bank.id }
    }
    
    enum Mode: Equatable {
        
        case collapsed, expanded
    }
    
    enum Status: Equatable {
        
        case failure(Failure)
        case inflight
        
        enum Failure: Equatable {
            
            case connectivityError
            case serverError(String)
        }
    }
}
